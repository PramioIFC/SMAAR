import 'dart:async';
import 'package:flutter/material.dart';
import 'models/models.dart';
import 'utils/date_utils.dart';
import 'repositories/repositories/gate_repository.dart';
import 'services/api_client.dart';

/// Estado global da aplicação.
///
/// Fonte da verdade: backend Django.
/// Cache em memória para leitura síncrona nas telas —
/// populado via API no login e atualizado após cada ação.
class AppStateData extends ChangeNotifier {
  final GateRepository _gateRepo;

  // ── Sessão ─────────────────────────────────────────────────────────────────
  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  bool _loadingGates = false;
  bool get loadingGates => _loadingGates;

  bool _polling = false;

  AppStateData({required GateRepository gateRepo}) : _gateRepo = gateRepo;

  // ── Porteiras ──────────────────────────────────────────────────────────────
  final List<Gate> _gates = [];
  List<Gate> get gates => List.unmodifiable(_gates);

  // ── Eventos por porteira × data ────────────────────────────────────────────
  final Map<int, Map<String, List<DayEvent>>> _events = {};

  // ── Logs de calendário por porteira ───────────────────────────────────────
  final Map<int, List<DayLog>> _logs = {};

  // ── Login / Logout ─────────────────────────────────────────────────────────

  Future<void> login(User user) async {
    _currentUser = user;
    notifyListeners();
    await _reloadAll();
    _startPolling();
  }

  Future<void> logout() async {
    _stopPolling();
    _currentUser = null;
    _gates.clear();
    _events.clear();
    _logs.clear();
    await ApiClient().clearTokens();
    notifyListeners();
  }

  // [NOVO] Restaura a sessão a partir do token JWT já salvo no FlutterSecureStorage.
  //
  // Chamado no boot do app (main.dart/_SmaarAppState.initState) para evitar que
  // o usuário precise fazer login toda vez que fechar e reabrir o app.
  //
  // Fluxo:
  //   1. Chama GET /api/me/ com o token salvo
  //   2. Se OK → popula _currentUser e carrega os dados normalmente
  //   3. Se falhar (token expirado/inválido) → limpa os tokens e retorna false
  //      (o _AuthGuard vai redirecionar para /login naturalmente)
  Future<bool> reloadFromToken() async {
    try {
      final data = await ApiClient().get('/me/') as Map<String, dynamic>;
      _currentUser = User(
        id:   data['id']       as int,
        name: data['username'] as String,
      );
      notifyListeners();
      await _reloadAll();
      _startPolling();
      return true;
    } catch (_) {
      // Token expirado, inválido ou servidor inacessível — força novo login
      await ApiClient().clearTokens();
      _stopPolling();
      return false;
    }
  }

  // ── Carga completa do backend ──────────────────────────────────────────────

  Future<void> _reloadAll() async {
    if (_currentUser?.id == null) return;
    _loadingGates = true;
    notifyListeners();

    try {
      final gates = await _gateRepo.getGatesForUser(_currentUser!.id!);
      _gates
        ..clear()
        ..addAll(gates);
      _events.clear();
      _logs.clear();

      for (final gate in gates) {
        if (gate.id == null) continue;
        await _loadHistoryForGate(gate.id!);
      }
    } finally {
      _loadingGates = false;
      notifyListeners();
    }
  }

  // ── Polling sequencial ────────────────────────────────────────────────────
  // Em vez de Timer.periodic (que atropela requisições), usamos um loop
  // assíncrono que só espera 3s DEPOIS de cada checagem terminar.

  void _startPolling() {
    if (_polling) return;
    _polling = true;
    _pollLoop();
  }

  void _stopPolling() {
    _polling = false;
  }

  Future<void> _pollLoop() async {
    while (_polling && _currentUser != null) {
      await Future.delayed(const Duration(seconds: 3));
      if (!_polling || _currentUser == null) break;
      await _silentReloadGates();
    }
  }

  Future<void> _silentReloadGates() async {
    if (_currentUser?.id == null) return;
    try {
      final updatedGates = await _gateRepo.getGatesForUser(_currentUser!.id!);
      bool changed = false;
      
      for (final newGate in updatedGates) {
        final idx = _gates.indexWhere((g) => g.id == newGate.id);
        if (idx != -1) {
          if (_gates[idx].isClosed != newGate.isClosed) {
            _gates[idx] = newGate;
            changed = true;
            if (newGate.id != null) {
               await _loadHistoryForGate(newGate.id!);
            }
          }
        }
      }
      
      if (changed) {
        notifyListeners();
      }
    } catch (_) {
      // Ignore poll errors to avoid disrupting user experience
    }
  }

  Future<void> _loadHistoryForGate(int gateId) async {
    final registros =
        (await _gateRepo.getRegistrosForGate(gateId)).reversed.toList();

    final byDate = <String, List<DayEvent>>{};
    for (final e in registros) {
      byDate.putIfAbsent(DateHelper.dateToKey(e.date), () => []).add(e);
    }
    _events[gateId] = byDate;

    _logs[gateId] = byDate.entries.map((entry) {
      final last     = entry.value.last;
      final isClosed = last.iconName == 'lock';
      return DayLog.fromStatusEntry(
        gateId: gateId,
        date:   last.date,
        status: isClosed ? 'fechado' : 'aberto',
      );
    }).toList();
  }

  // ── Leitura ────────────────────────────────────────────────────────────────

  Gate? gateById(int id) {
    try {
      return _gates.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  List<DayEvent> eventsForGateAndKey(int gateId, String dateKey) =>
      List.unmodifiable(_events[gateId]?[dateKey] ?? []);

  List<DayEvent> eventsForKey(String dateKey) =>
      _events.values.expand((m) => m[dateKey] ?? <DayEvent>[]).toList();

  Map<String, DayLog> logsForGateAndMonth(int gateId, int year, int month) {
    final result = <String, DayLog>{};
    for (final log in _logs[gateId] ?? []) {
      if (log.date.year == year && log.date.month == month) {
        result[log.dateKey] = log;
      }
    }
    return result;
  }

  Map<String, DayLog> logsForMonth(int year, int month) {
    final result = <String, DayLog>{};
    for (final logs in _logs.values) {
      for (final log in logs) {
        if (log.date.year == year && log.date.month == month) {
          result[log.dateKey] = log;
        }
      }
    }
    return result;
  }

  DayEvent? lastEventForGate(int gateId) {
    final map = _events[gateId];
    if (map == null || map.isEmpty) return null;
    for (final key in (map.keys.toList()..sort((a, b) => b.compareTo(a)))) {
      final list = map[key];
      if (list != null && list.isNotEmpty) return list.last;
    }
    return null;
  }

  // ── Mutação ────────────────────────────────────────────────────────────────

  Future<void> toggleGate(int gateId, bool close) async {
    final idx = _gates.indexWhere((g) => g.id == gateId);
    if (idx == -1) return;

    try {
      // 1. Aguarda confirmação do backend (que agora aguarda o Arduino)
      final registro = await _gateRepo.updateGateStatus(gateId, close);
      
      // 2. Só agora atualiza o estado local
      _gates[idx] = _gates[idx].copyWith(isClosed: close);

      final key = DateHelper.dateToKey(registro.date);
      _events
          .putIfAbsent(gateId, () => {})
          .putIfAbsent(key, () => [])
          .add(registro);

      final logList  = _logs.putIfAbsent(gateId, () => []);
      final existIdx = logList.indexWhere((l) => l.dateKey == key);
      final newLog   = DayLog.fromStatusEntry(
        gateId: gateId,
        date:   registro.date,
        status: close ? 'fechado' : 'aberto',
      );
      if (existIdx == -1) {
        logList.add(newLog);
      } else {
        logList[existIdx] = newLog;
      }
      notifyListeners();
    } catch (e) {
      // O erro já é propagado para a UI exibir a mensagem correta (ex: Arduino offline)
      rethrow;  
    }
  }

  Future<void> deleteGate(int gateId) async {
    await _gateRepo.deleteGate(gateId);
    _gates.removeWhere((g) => g.id == gateId);
    _events.remove(gateId);
    _logs.remove(gateId);
    notifyListeners();
  }

  Future<void> addGate(Gate gate) async {
    if (_currentUser?.id == null) return;
    final persisted =
        await _gateRepo.createGate(gate, ownerId: _currentUser!.id!);
    _gates.add(persisted);
    if (persisted.id != null) {
      _events[persisted.id!] = {};
      _logs[persisted.id!]   = [];
    }
    notifyListeners();
  }

  Future<void> updateGate(Gate updatedGate) async {
    if (updatedGate.id == null) return;
    final persisted = await _gateRepo.updateGate(updatedGate);
    final idx = _gates.indexWhere((g) => g.id == persisted.id);
    if (idx != -1) {
      _gates[idx] = persisted;
      notifyListeners();
    }
  }
}

// ── InheritedNotifier ─────────────────────────────────────────────────────────

class AppState extends InheritedNotifier<AppStateData> {
  const AppState({
    super.key,
    required AppStateData state,
    required super.child,
  }) : super(notifier: state);

  static AppStateData of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<AppState>();
    assert(inherited != null, 'AppState não encontrado na árvore de widgets');
    return inherited!.notifier!;
  }
}
