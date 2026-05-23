import '../../models/models.dart';
import '../../utils/date_utils.dart';

abstract class LogRepository {
  Future<List<DayLog>> getAllLogs();
  Future<DayLog?> getLogForDate(DateTime date);
  Future<DayLog?> getLogForDay(int year, int month, int day);
  Future<Map<String, DayLog>> getLogsForMonth(int year, int month);
  Future<Map<String, DayLog>> getLogsForGateAndMonth(
      int gateId, int year, int month);
}

class MockLogRepository implements LogRepository {
  // Status por porteira, espelhando os eventos do MockEventRepository:
  //
  // Porteira 1: hoje=normal, ontem=warning(wifi), 2d=normal, 3d=warning(sensor), 4d=normal, 5d=normal
  // Porteira 2: hoje=normal, ontem=danger(motor), 2d=normal, 3d=warning(sensor), 4d=normal, 5d=normal
  // Porteira 3: hoje=warning(wifi), ontem=normal, 2d=warning(sensor), 3d=normal, 4d=normal, 5d=normal

  late final Map<int, List<DayLog>> _byGate;

  MockLogRepository() {
    final now = DateTime.now();

    DateTime day(int n) {
      final d = now.subtract(Duration(days: n));
      return DateTime(d.year, d.month, d.day);
    }

    _byGate = {
      1: [
        DayLog(id: 11, gateId: 1, date: day(0), status: LogStatus.normal),
        DayLog(id: 12, gateId: 1, date: day(1), status: LogStatus.warning,
            description: "Queda de internet"),
        DayLog(id: 13, gateId: 1, date: day(2), status: LogStatus.normal),
        DayLog(id: 14, gateId: 1, date: day(3), status: LogStatus.warning,
            description: "Sensor offline"),
        DayLog(id: 15, gateId: 1, date: day(4), status: LogStatus.normal),
        DayLog(id: 16, gateId: 1, date: day(5), status: LogStatus.normal),
      ],
      2: [
        DayLog(id: 21, gateId: 2, date: day(0), status: LogStatus.normal),
        DayLog(id: 22, gateId: 2, date: day(1), status: LogStatus.danger,
            description: "Falha crítica no motor"),
        DayLog(id: 23, gateId: 2, date: day(2), status: LogStatus.normal),
        DayLog(id: 24, gateId: 2, date: day(3), status: LogStatus.warning,
            description: "Sensor offline"),
        DayLog(id: 25, gateId: 2, date: day(4), status: LogStatus.normal),
        DayLog(id: 26, gateId: 2, date: day(5), status: LogStatus.normal),
      ],
      3: [
        DayLog(id: 31, gateId: 3, date: day(0), status: LogStatus.warning,
            description: "Queda de internet"),
        DayLog(id: 32, gateId: 3, date: day(1), status: LogStatus.normal),
        DayLog(id: 33, gateId: 3, date: day(2), status: LogStatus.warning,
            description: "Sensor offline"),
        DayLog(id: 34, gateId: 3, date: day(3), status: LogStatus.normal),
        DayLog(id: 35, gateId: 3, date: day(4), status: LogStatus.normal),
        DayLog(id: 36, gateId: 3, date: day(5), status: LogStatus.normal),
      ],
    };
  }

  List<DayLog> get _allLogs =>
      _byGate.values.expand((list) => list).toList();

  @override
  Future<List<DayLog>> getAllLogs() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_allLogs);
  }

  @override
  Future<DayLog?> getLogForDate(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final key = DateHelper.dateToKey(date);
    try {
      return _allLogs.firstWhere((l) => l.dateKey == key);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<DayLog?> getLogForDay(int year, int month, int day) async {
    return getLogForDate(DateTime(year, month, day));
  }

  @override
  Future<Map<String, DayLog>> getLogsForMonth(int year, int month) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final result = <String, DayLog>{};
    for (final log in _allLogs) {
      if (log.date.year == year && log.date.month == month) {
        result[log.dateKey] = log;
      }
    }
    return result;
  }

  @override
  Future<Map<String, DayLog>> getLogsForGateAndMonth(
      int gateId, int year, int month) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final result = <String, DayLog>{};
    for (final log in _byGate[gateId] ?? []) {
      if (log.date.year == year && log.date.month == month) {
        result[log.dateKey] = log;
      }
    }
    return result;
  }
}

// Exposição dos dados brutos para o bootstrap do AppState
extension MockLogRepositoryAccess on MockLogRepository {
  Map<int, List<DayLog>> get rawByGate {
    final copy = <int, List<DayLog>>{};
    for (final entry in _byGate.entries) {
      copy[entry.key] = List<DayLog>.from(entry.value);
    }
    return copy;
  }
}
