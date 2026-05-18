import '/models/models.dart';
import '/utils/date_utils.dart';

abstract class EventRepository {
  Future<List<DayEvent>> getEventsForDate(DateTime date);
  Future<List<DayEvent>> getEventsForDateKey(String dateKey);
  Future<List<DayEvent>> getEventsForGateAndDateKey(int gateId, String dateKey);
}

class MockEventRepository implements EventRepository {
  late final Map<int, Map<String, List<DayEvent>>> _byGate;

  MockEventRepository() {
    final now = DateTime.now();

    DateTime day(int n) {
      final d = now.subtract(Duration(days: n));
      return DateTime(d.year, d.month, d.day);
    }

    String k(int n) => DateHelper.dateToKey(day(n));

    // ── Porteira 1 ─────────────────────────────────────────────────
    // Comportamento: opera bem, mas teve queda de internet ontem
    _byGate = {
      1: {
        k(0): [
          DayEvent(id: 101, gateId: 1, date: day(0), time: "06:30",
              title: "Porteira aberta", subtitle: "Abertura automática programada",
              iconName: "lock_open", type: EventType.normal),
          DayEvent(id: 102, gateId: 1, date: day(0), time: "18:45",
              title: "Porteira fechada", subtitle: "Fechamento automático programado",
              iconName: "lock", type: EventType.normal),
        ],
        k(1): [
          DayEvent(id: 103, gateId: 1, date: day(1), time: "06:30",
              title: "Porteira aberta", subtitle: "Abertura automática programada",
              iconName: "lock_open", type: EventType.normal),
          DayEvent(id: 104, gateId: 1, date: day(1), time: "11:14",
              title: "Internet caiu", subtitle: "Dispositivo sem conexão",
              iconName: "wifi_off", type: EventType.warning),
          DayEvent(id: 105, gateId: 1, date: day(1), time: "11:22",
              title: "Internet restaurada", subtitle: "Conexão reestabelecida",
              iconName: "wifi", type: EventType.normal),
          DayEvent(id: 106, gateId: 1, date: day(1), time: "19:00",
              title: "Porteira fechada", subtitle: "Fechamento automático programado",
              iconName: "lock", type: EventType.normal),
        ],
        k(2): [
          DayEvent(id: 107, gateId: 1, date: day(2), time: "06:30",
              title: "Porteira aberta", subtitle: "Abertura automática programada",
              iconName: "lock_open", type: EventType.normal),
          DayEvent(id: 108, gateId: 1, date: day(2), time: "18:30",
              title: "Porteira fechada", subtitle: "Fechamento automático programado",
              iconName: "lock", type: EventType.normal),
        ],
        k(3): [
          DayEvent(id: 109, gateId: 1, date: day(3), time: "06:30",
              title: "Porteira aberta", subtitle: "Abertura automática programada",
              iconName: "lock_open", type: EventType.normal),
          DayEvent(id: 110, gateId: 1, date: day(3), time: "08:55",
              title: "Sensor offline", subtitle: "Sensor de presença sem resposta",
              iconName: "sensors_off", type: EventType.warning),
          DayEvent(id: 111, gateId: 1, date: day(3), time: "09:03",
              title: "Sensor normalizado", subtitle: "Sensor voltou a responder",
              iconName: "sensors", type: EventType.normal),
          DayEvent(id: 112, gateId: 1, date: day(3), time: "18:30",
              title: "Porteira fechada", subtitle: "Fechamento automático programado",
              iconName: "lock", type: EventType.normal),
        ],
        k(4): [
          DayEvent(id: 113, gateId: 1, date: day(4), time: "06:30",
              title: "Porteira aberta", subtitle: "Abertura automática programada",
              iconName: "lock_open", type: EventType.normal),
          DayEvent(id: 114, gateId: 1, date: day(4), time: "18:30",
              title: "Porteira fechada", subtitle: "Fechamento automático programado",
              iconName: "lock", type: EventType.normal),
        ],
        k(5): [
          DayEvent(id: 115, gateId: 1, date: day(5), time: "06:30",
              title: "Porteira aberta", subtitle: "Abertura automática programada",
              iconName: "lock_open", type: EventType.normal),
          DayEvent(id: 116, gateId: 1, date: day(5), time: "18:30",
              title: "Porteira fechada", subtitle: "Fechamento automático programado",
              iconName: "lock", type: EventType.normal),
        ],
      },

      // ── Porteira 2 ─────────────────────────────────────────────────
      // Comportamento: teve falha grave ontem (motor), sensor caiu há 3 dias
      2: {
        k(0): [
          DayEvent(id: 201, gateId: 2, date: day(0), time: "09:00",
              title: "Porteira aberta", subtitle: "Abertura manual pelo usuário",
              iconName: "lock_open", type: EventType.normal),
          DayEvent(id: 202, gateId: 2, date: day(0), time: "22:00",
              title: "Porteira fechada", subtitle: "Fechamento manual pelo usuário",
              iconName: "lock", type: EventType.normal),
        ],
        k(1): [
          DayEvent(id: 203, gateId: 2, date: day(1), time: "09:00",
              title: "Porteira aberta", subtitle: "Abertura manual pelo usuário",
              iconName: "lock_open", type: EventType.normal),
          DayEvent(id: 204, gateId: 2, date: day(1), time: "14:30",
              title: "Falha crítica", subtitle: "Motor sem resposta",
              iconName: "warning", type: EventType.danger),
          DayEvent(id: 205, gateId: 2, date: day(1), time: "15:10",
              title: "Manutenção acionada", subtitle: "Técnico solicitado",
              iconName: "build", type: EventType.warning),
        ],
        k(2): [
          DayEvent(id: 206, gateId: 2, date: day(2), time: "09:00",
              title: "Porteira aberta", subtitle: "Abertura manual pelo usuário",
              iconName: "lock_open", type: EventType.normal),
          DayEvent(id: 207, gateId: 2, date: day(2), time: "21:30",
              title: "Porteira fechada", subtitle: "Fechamento manual pelo usuário",
              iconName: "lock", type: EventType.normal),
        ],
        k(3): [
          DayEvent(id: 208, gateId: 2, date: day(3), time: "09:00",
              title: "Porteira aberta", subtitle: "Abertura manual pelo usuário",
              iconName: "lock_open", type: EventType.normal),
          DayEvent(id: 209, gateId: 2, date: day(3), time: "16:40",
              title: "Sensor offline", subtitle: "Sensor de presença sem resposta",
              iconName: "sensors_off", type: EventType.warning),
          DayEvent(id: 210, gateId: 2, date: day(3), time: "16:51",
              title: "Sensor normalizado", subtitle: "Sensor voltou a responder",
              iconName: "sensors", type: EventType.normal),
          DayEvent(id: 211, gateId: 2, date: day(3), time: "21:00",
              title: "Porteira fechada", subtitle: "Fechamento manual pelo usuário",
              iconName: "lock", type: EventType.normal),
        ],
        k(4): [
          DayEvent(id: 212, gateId: 2, date: day(4), time: "09:00",
              title: "Porteira aberta", subtitle: "Abertura manual pelo usuário",
              iconName: "lock_open", type: EventType.normal),
          DayEvent(id: 213, gateId: 2, date: day(4), time: "22:00",
              title: "Porteira fechada", subtitle: "Fechamento manual pelo usuário",
              iconName: "lock", type: EventType.normal),
        ],
        k(5): [
          DayEvent(id: 214, gateId: 2, date: day(5), time: "09:00",
              title: "Porteira aberta", subtitle: "Abertura manual pelo usuário",
              iconName: "lock_open", type: EventType.normal),
          DayEvent(id: 215, gateId: 2, date: day(5), time: "22:00",
              title: "Porteira fechada", subtitle: "Fechamento manual pelo usuário",
              iconName: "lock", type: EventType.normal),
        ],
      },

      // ── Porteira 3 ─────────────────────────────────────────────────
      // Comportamento: internet instável hoje, sensor caiu há 2 dias
      3: {
        k(0): [
          DayEvent(id: 301, gateId: 3, date: day(0), time: "09:00",
              title: "Porteira aberta", subtitle: "Abertura automática programada",
              iconName: "lock_open", type: EventType.normal),
          DayEvent(id: 302, gateId: 3, date: day(0), time: "13:05",
              title: "Internet caiu", subtitle: "Dispositivo sem conexão",
              iconName: "wifi_off", type: EventType.warning),
          DayEvent(id: 303, gateId: 3, date: day(0), time: "13:18",
              title: "Internet restaurada", subtitle: "Conexão reestabelecida",
              iconName: "wifi", type: EventType.normal),
          DayEvent(id: 304, gateId: 3, date: day(0), time: "22:00",
              title: "Porteira fechada", subtitle: "Fechamento automático programado",
              iconName: "lock", type: EventType.normal),
        ],
        k(1): [
          DayEvent(id: 305, gateId: 3, date: day(1), time: "09:00",
              title: "Porteira aberta", subtitle: "Abertura automática programada",
              iconName: "lock_open", type: EventType.normal),
          DayEvent(id: 306, gateId: 3, date: day(1), time: "22:00",
              title: "Porteira fechada", subtitle: "Fechamento automático programado",
              iconName: "lock", type: EventType.normal),
        ],
        k(2): [
          DayEvent(id: 307, gateId: 3, date: day(2), time: "09:00",
              title: "Porteira aberta", subtitle: "Abertura automática programada",
              iconName: "lock_open", type: EventType.normal),
          DayEvent(id: 308, gateId: 3, date: day(2), time: "10:30",
              title: "Sensor offline", subtitle: "Sensor de presença sem resposta",
              iconName: "sensors_off", type: EventType.warning),
          DayEvent(id: 309, gateId: 3, date: day(2), time: "10:44",
              title: "Sensor normalizado", subtitle: "Sensor voltou a responder",
              iconName: "sensors", type: EventType.normal),
          DayEvent(id: 310, gateId: 3, date: day(2), time: "22:00",
              title: "Porteira fechada", subtitle: "Fechamento automático programado",
              iconName: "lock", type: EventType.normal),
        ],
        k(3): [
          DayEvent(id: 311, gateId: 3, date: day(3), time: "09:00",
              title: "Porteira aberta", subtitle: "Abertura automática programada",
              iconName: "lock_open", type: EventType.normal),
          DayEvent(id: 312, gateId: 3, date: day(3), time: "22:00",
              title: "Porteira fechada", subtitle: "Fechamento automático programado",
              iconName: "lock", type: EventType.normal),
        ],
        k(4): [
          DayEvent(id: 313, gateId: 3, date: day(4), time: "09:00",
              title: "Porteira aberta", subtitle: "Abertura automática programada",
              iconName: "lock_open", type: EventType.normal),
          DayEvent(id: 314, gateId: 3, date: day(4), time: "22:00",
              title: "Porteira fechada", subtitle: "Fechamento automático programado",
              iconName: "lock", type: EventType.normal),
        ],
        k(5): [
          DayEvent(id: 315, gateId: 3, date: day(5), time: "09:00",
              title: "Porteira aberta", subtitle: "Abertura automática programada",
              iconName: "lock_open", type: EventType.normal),
          DayEvent(id: 316, gateId: 3, date: day(5), time: "22:00",
              title: "Porteira fechada", subtitle: "Fechamento automático programado",
              iconName: "lock", type: EventType.normal),
        ],
      },
    };
  }

  @override
  Future<List<DayEvent>> getEventsForDate(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final key = DateHelper.dateToKey(date);
    return _byGate.values
        .expand((m) => m[key] ?? <DayEvent>[])
        .toList();
  }

  @override
  Future<List<DayEvent>> getEventsForDateKey(String dateKey) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _byGate.values
        .expand((m) => m[dateKey] ?? <DayEvent>[])
        .toList();
  }

  @override
  Future<List<DayEvent>> getEventsForGateAndDateKey(
      int gateId, String dateKey) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _byGate[gateId]?[dateKey] ?? [];
  }
}
