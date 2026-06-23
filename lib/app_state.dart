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
  }

  Future<void> logout() async {
    _currentUser = null;
    _gates.clear();
    _events.clear();
    _logs.clear();
    await ApiClient().clearTokens();
    notifyListeners();
  }

  // ── Carga completa do backend ──────────────────────────────────────────────

  Future<void> _reloadAll() async {
    if (_currentUser?.id == null) return;
    _loadingGates = true;
    notifyListeners();

    try {
      final gates = await _gateRepo.getGatesForUser(_currentUser!.id!);
      _gates..clear()..addAll(gates);
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

  Future<void> _loadHistoryForGate(int gateId) async {
    // Backend devolve mais recente primeiro; invertemos para cronológico
    final registros = (await _gateRepo.getRegistrosForGate(gateId)).reversed.toList();

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
    try { return _gates.firstWhere((g) => g.id == id); } catch (_) { return null; }
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

  /// Abre/fecha a porteira.
  /// Atualiza a UI imediatamente (otimista) e confirma com o backend;
  /// reverte se o servidor recusar.
  void toggleGate(int gateId, bool close) {
    final idx = _gates.indexWhere((g) => g.id == gateId);
    if (idx == -1) return;

    final prev = _gates[idx];
    _gates[idx] = prev.copyWith(isClosed: close);
    notifyListeners();

    _gateRepo.updateGateStatus(gateId, close).then((registro) {
      final key = DateHelper.dateToKey(registro.date);
      _events.putIfAbsent(gateId, () => {})
             .putIfAbsent(key, () => [])
             .add(registro);

      final logList = _logs.putIfAbsent(gateId, () => []);
      final existIdx = logList.indexWhere((l) => l.dateKey == key);
      final newLog = DayLog.fromStatusEntry(
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
    }).catchError((_) {
      // Reverte atualização otimista
      final i = _gates.indexWhere((g) => g.id == gateId);
      if (i != -1) _gates[i] = prev;
      notifyListeners();
    });
  }

  /// Cadastra nova porteira no backend e adiciona ao cache.
  Future<void> addGate(Gate gate) async {
    if (_currentUser?.id == null) return;
    final persisted = await _gateRepo.createGate(gate, ownerId: _currentUser!.id!);
    _gates.add(persisted);
    if (persisted.id != null) {
      _events[persisted.id!] = {};
      _logs[persisted.id!]   = [];
    }
    notifyListeners();
  }
}

// ── InheritedNotifier ─────────────────────────────────────────────────────────

class AppState extends InheritedNotifier<AppStateData> {
  const AppState({super.key, required AppStateData state, required super.child})
      : super(notifier: state);

  static AppStateData of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<AppState>();
    assert(inherited != null, 'AppState não encontrado na árvore de widgets');
    return inherited!.notifier!;
  }
}
