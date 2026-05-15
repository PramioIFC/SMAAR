import '/models/models.dart';
import '/utils/date_utils.dart';

/// Repository para gerenciar logs do calendário
/// Atualmente usa dados mock, preparado para PostgreSQL
abstract class LogRepository {
  Future<List<DayLog>> getAllLogs();
  Future<DayLog?> getLogForDate(DateTime date);
  Future<DayLog?> getLogForDay(int year, int month, int day);
  Future<Map<String, DayLog>> getLogsForMonth(int year, int month);
}

/// Implementação mock do LogRepository
/// Os status batem exatamente com os eventos do MockEventRepository:
///   hoje      → warning  (tem wifi_off)
///   ontem     → danger   (motor sem resposta)
///   2 dias    → normal
///   3 dias    → warning  (falha no sensor)
///   4 dias    → normal
///   5 dias    → normal
class MockLogRepository implements LogRepository {
  late final List<DayLog> _allLogs;

  MockLogRepository() {
    final now = DateTime.now();

    DateTime day(int daysAgo) {
      final d = now.subtract(Duration(days: daysAgo));
      return DateTime(d.year, d.month, d.day);
    }

    _allLogs = [
      DayLog(id: 1, date: day(0), status: LogStatus.warning,
          description: "Alerta / Atenção"),
      DayLog(id: 2, date: day(1), status: LogStatus.danger,
          description: "Problema / Falha"),
      DayLog(id: 3, date: day(2), status: LogStatus.normal,
          description: "Uso normal"),
      DayLog(id: 4, date: day(3), status: LogStatus.warning,
          description: "Alerta / Atenção"),
      DayLog(id: 5, date: day(4), status: LogStatus.normal,
          description: "Uso normal"),
      DayLog(id: 6, date: day(5), status: LogStatus.normal,
          description: "Uso normal"),
    ];
  }

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
      return _allLogs.firstWhere((log) => log.dateKey == key);
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
}
