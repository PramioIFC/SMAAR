import 'package:flutter/material.dart';
import 'models/models.dart';
import 'utils/date_utils.dart';
import 'repositories/repositories/gate_repository.dart';

/// Estado global do app — sessão do usuário + porteiras + eventos + logs.
///
/// Usa [GateRepository] para persistência das porteiras.
/// Hoje: MockGateRepository (memória).
/// Depois: troque por PostgresGateRepository sem mudar este arquivo.
class AppStateData extends ChangeNotifier {
  // ── Repositório de porteiras ───────────────────────────────────────────────
  final GateRepository _gateRepo;

  // ── Sessão ─────────────────────────────────────────────────────────────────
  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Inicia sessão: carrega as porteiras do usuário do repositório.
  Future<void> login(User user) async {
    _currentUser = user;

    // Busca as porteiras do usuário no repositório.
    // Guarda com null-check seguro — id só será null se o repositório
    // retornar um usuário sem id (não acontece no mock nem no PostgreSQL
    // com SERIAL, mas protege contra regressões futuras).
    // PostgreSQL: SELECT * FROM gates WHERE owner_id = @userId
    if (user.id != null) {
      final gates = await _gateRepo.getGatesForUser(user.id!);
      _allGates
        ..clear()
        ..addAll(gates);
    }

    notifyListeners();
  }

  /// Encerra a sessão e limpa todas as porteiras da memória.
  void logout() {
    _currentUser = null;
    _allGates.clear();
    notifyListeners();
  }

  // ── Porteiras ──────────────────────────────────────────────────────────────

  final List<Gate> _allGates = [];

  /// Porteiras do usuário logado (já filtradas pelo login).
  List<Gate> get gates => List.unmodifiable(_allGates);

  // ── Eventos por porteira e data ────────────────────────────────────────────
  final Map<int, Map<String, List<DayEvent>>> _events;

  // ── Logs do calendário por porteira ───────────────────────────────────────
  final Map<int, List<DayLog>> _logs;

  int _nextEventId = 2000;
  int _nextLogId   = 1000;

  AppStateData({
    required GateRepository gateRepo,
    required Map<int, Map<String, List<DayEvent>>> events,
    required Map<int, List<DayLog>> logs,
  })  : _gateRepo = gateRepo,
        _events   = events,
        _logs     = logs;

  // ── Leitura ────────────────────────────────────────────────────────────────

  Gate? gateById(int id) {
    try {
      return _allGates.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  List<DayEvent> eventsForGateAndKey(int gateId, String dateKey) =>
      List.unmodifiable(_events[gateId]?[dateKey] ?? []);

  List<DayEvent> eventsForKey(String dateKey) => _events.values
      .expand((m) => m[dateKey] ?? <DayEvent>[])
      .toList();

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
    final gateMap = _events[gateId];
    if (gateMap == null || gateMap.isEmpty) return null;

    final sortedKeys = gateMap.keys.toList()..sort((a, b) => b.compareTo(a));
    for (final key in sortedKeys) {
      final list = gateMap[key];
      if (list != null && list.isNotEmpty) return list.last;
    }
    return null;
  }

  // ── Mutação ────────────────────────────────────────────────────────────────

  /// Alterna o status de uma porteira e registra o evento/log.
  ///
  /// Chama [GateRepository.updateGateStatus] para persistir.
  /// PostgreSQL: UPDATE gates SET is_closed = @isClosed WHERE id = @id
  void toggleGate(int gateId, bool close) {
    final idx = _allGates.indexWhere((g) => g.id == gateId);
    if (idx == -1) return;

    final now      = DateTime.now();
    final timeStr  = '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
    final dateOnly = DateTime(now.year, now.month, now.day);
    final dateKey  = DateHelper.dateToKey(dateOnly);

    // Atualiza em memória imediatamente (UI não espera o repo)
    _allGates[idx] = _allGates[idx].copyWith(isClosed: close);

    // Persiste no repositório em background
    // PostgreSQL: UPDATE gates SET is_closed = @isClosed WHERE id = @id
    _gateRepo.updateGateStatus(gateId, close);

    final newEvent = DayEvent(
      id: _nextEventId++,
      gateId: gateId,
      date: dateOnly,
      time: timeStr,
      title: close ? 'Porteira fechada' : 'Porteira aberta',
      subtitle: close
          ? 'Fechamento manual pelo usuário'
          : 'Abertura manual pelo usuário',
      iconName: close ? 'lock' : 'lock_open',
      type: EventType.normal,
    );

    _events.putIfAbsent(gateId, () => {});
    _events[gateId]!.putIfAbsent(dateKey, () => []);
    _events[gateId]![dateKey]!.add(newEvent);

    _logs.putIfAbsent(gateId, () => []);
    final logList     = _logs[gateId]!;
    final existingIdx = logList.indexWhere((l) => l.dateKey == dateKey);
    final newLog = DayLog(
      id: existingIdx == -1 ? _nextLogId++ : logList[existingIdx].id,
      gateId: gateId,
      date: dateOnly,
      status: LogStatus.normal,
      description: close ? 'Fechamento manual' : 'Abertura manual',
    );
    if (existingIdx == -1) {
      logList.add(newLog);
    } else {
      logList[existingIdx] = newLog;
    }

    notifyListeners();
  }

  /// Cadastra uma nova porteira, persiste no repositório e vincula ao usuário.
  ///
  /// PostgreSQL:
  ///   INSERT INTO gates (..., owner_id) VALUES (..., @userId) RETURNING *;
  Future<void> addGate(Gate gate) async {
    if (_currentUser?.id == null) return;

    // Persiste e obtém o gate com id atribuído pelo repositório
    // (mock: id gerado localmente; PostgreSQL: id gerado pelo SERIAL)
    final persisted = await _gateRepo.createGate(
      gate,
      ownerId: _currentUser!.id!,
    );

    _allGates.add(persisted);
    notifyListeners();
  }
}

// ── InheritedNotifier wrapper ──────────────────────────────────────────────

class AppState extends InheritedNotifier<AppStateData> {
  const AppState({
    super.key,
    required AppStateData state,
    required super.child,
  }) : super(notifier: state);

  static AppStateData of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<AppState>();
    assert(inherited != null, 'AppState não encontrado na árvore de widgets');
    return inherited!.notifier!;
  }
}
