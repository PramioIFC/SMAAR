import 'package:flutter/material.dart';
import 'models/models.dart';
import 'utils/date_utils.dart';

/// Estado global do app — porteiras + eventos + logs, todos mutáveis em memória.
/// Use AppState.of(context) para ler e AppState.update(context, ...) para escrever.
class AppStateData extends ChangeNotifier {
  // ── Porteiras ──────────────────────────────────────────────────────────────
  // Lista privada — acesso externo via getter imutável para evitar mutação acidental
  final List<Gate> _gates;

  /// Visão somente-leitura da lista de porteiras.
  List<Gate> get gates => List.unmodifiable(_gates);

  // ── Eventos por porteira e data ────────────────────────────────────────────
  // Estrutura: { gateId: { dateKey: [DayEvent, ...] } }
  final Map<int, Map<String, List<DayEvent>>> _events;

  // ── Logs do calendário por porteira ────────────────────────────────────────
  // Estrutura: { gateId: [DayLog, ...] }
  final Map<int, List<DayLog>> _logs;

  // Contadores para IDs novos — iniciam acima do maior ID mock (max ~316/36)
  int _nextEventId = 2000;
  int _nextLogId = 1000;

  AppStateData({
    required List<Gate> gates,
    required Map<int, Map<String, List<DayEvent>>> events,
    required Map<int, List<DayLog>> logs,
  })  : _gates = gates,
        _events = events,
        _logs = logs;

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

    // Percorre as chaves ordenadas desc e retorna o último evento do dia mais recente
    final sortedKeys = gateMap.keys.toList()..sort((a, b) => b.compareTo(a));
    for (final key in sortedKeys) {
      final list = gateMap[key];
      if (list != null && list.isNotEmpty) return list.last;
    }
    return null;
  }

  // ── Mutação ────────────────────────────────────────────────────────────────

  /// Alterna o estado da porteira e registra o evento + log correspondente.
  void toggleGate(int gateId, bool close) {
    final idx = _gates.indexWhere((g) => g.id == gateId);
    if (idx == -1) return;

    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final dateOnly = DateTime(now.year, now.month, now.day);
    final dateKey = DateHelper.dateToKey(dateOnly);

    // 1. Atualiza porteira
    _gates[idx] = _gates[idx].copyWith(isClosed: close);

    // 2. Insere evento
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

    // 3. Upsert do log do dia (garante que hoje aparece no calendário)
    _logs.putIfAbsent(gateId, () => []);
    final logList = _logs[gateId]!;
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

  /// Adiciona nova porteira (vinda do RegisterGatePage).
  void addGate(Gate gate) {
    _gates.add(gate);
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
