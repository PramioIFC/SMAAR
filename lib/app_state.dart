import 'package:flutter/material.dart';
import 'models/models.dart';
import 'utils/date_utils.dart';

/// Estado global do app — sessão do usuário + porteiras + eventos + logs.
/// Use AppState.of(context) para ler e notifyListeners() para escrever.
class AppStateData extends ChangeNotifier {
  // ── Sessão ─────────────────────────────────────────────────────────────────

  User? _currentUser;

  /// Usuário autenticado no momento. Null quando não há sessão.
  User? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  /// Inicia sessão com o usuário retornado pelo AuthRepository.
  void login(User user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Encerra a sessão e limpa o estado da tela principal.
  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // ── Porteiras ──────────────────────────────────────────────────────────────

  final List<Gate> _allGates;

  /// Porteiras visíveis para o usuário logado.
  /// Admin vê [1, 2, 3]; outros usuários veem apenas suas próprias porteiras.
  List<Gate> get gates {
    final owned = _currentUser?.ownedGateIds ?? [];
    if (owned.isEmpty) return const [];
    return List.unmodifiable(
      _allGates.where((g) => owned.contains(g.id)).toList(),
    );
  }

  // ── Eventos por porteira e data ────────────────────────────────────────────
  final Map<int, Map<String, List<DayEvent>>> _events;

  // ── Logs do calendário por porteira ───────────────────────────────────────
  final Map<int, List<DayLog>> _logs;

  int _nextEventId = 2000;
  int _nextLogId   = 1000;

  AppStateData({
    required List<Gate> gates,
    required Map<int, Map<String, List<DayEvent>>> events,
    required Map<int, List<DayLog>> logs,
  })  : _allGates = gates,
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

  void toggleGate(int gateId, bool close) {
    final idx = _allGates.indexWhere((g) => g.id == gateId);
    if (idx == -1) return;

    final now     = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
    final dateOnly = DateTime(now.year, now.month, now.day);
    final dateKey  = DateHelper.dateToKey(dateOnly);

    _allGates[idx] = _allGates[idx].copyWith(isClosed: close);

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
    final logList    = _logs[gateId]!;
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

  void addGate(Gate gate) {
    _allGates.add(gate);

    // Vincula o id da nova porteira ao usuário logado para que
    // o getter `gates` (que filtra por ownedGateIds) a exiba
    if (_currentUser != null && gate.id != null) {
      _currentUser = _currentUser!.copyWith(
        ownedGateIds: [..._currentUser!.ownedGateIds, gate.id!],
      );
    }

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
