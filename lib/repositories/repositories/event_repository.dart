import '/models/models.dart';
import '/utils/date_utils.dart';

/// Repository para gerenciar eventos do dia
/// Atualmente usa dados mock, preparado para PostgreSQL
abstract class EventRepository {
  Future<List<DayEvent>> getEventsForDate(DateTime date);
  Future<List<DayEvent>> getEventsForDateKey(String dateKey);
}

/// Implementação mock do EventRepository
/// Substituir por implementação PostgreSQL quando integrar
class MockEventRepository implements EventRepository {
  // Dados mock organizados por data relativa ao dia atual
  // hoje = day(0), ontem = day(1), etc.
  late final Map<String, List<DayEvent>> _eventsByDay;

  MockEventRepository() {
    final now = DateTime.now();

    DateTime day(int daysAgo) {
      final d = now.subtract(Duration(days: daysAgo));
      return DateTime(d.year, d.month, d.day);
    }

    String key(int daysAgo) => DateHelper.dateToKey(day(daysAgo));

    _eventsByDay = {
      key(0): [
        DayEvent(
          id: 17,
          date: day(0),
          time: "07:14",
          title: "Porteira aberta",
          subtitle: "Aberta remotamente",
          iconName: "lock_open",
          type: EventType.normal,
        ),
        DayEvent(
          id: 18,
          date: day(0),
          time: "07:15",
          title: "João autorizou acesso",
          subtitle: "Acesso liberado manualmente",
          iconName: "verified_user",
          type: EventType.normal,
        ),
        DayEvent(
          id: 19,
          date: day(0),
          time: "09:52",
          title: "Caminhão entrou",
          subtitle: "Veículo detectado na entrada",
          iconName: "truck",
          type: EventType.info,
        ),
        DayEvent(
          id: 20,
          date: day(0),
          time: "12:03",
          title: "Porteira Sul offline",
          subtitle: "Sem sinal de conexão",
          iconName: "wifi_off",
          type: EventType.warning,
        ),
        DayEvent(
          id: 21,
          date: day(0),
          time: "12:10",
          title: "Reconectada",
          subtitle: "Conexão restabelecida",
          iconName: "wifi",
          type: EventType.normal,
        ),
        DayEvent(
          id: 22,
          date: day(0),
          time: "18:44",
          title: "Fechamento automático",
          subtitle: "Porteira fechada pelo sistema",
          iconName: "lock",
          type: EventType.normal,
        ),
      ],
      key(1): [
        DayEvent(
          id: 14,
          date: day(1),
          time: "07:00",
          title: "Porteira aberta",
          subtitle: "Abertura programada",
          iconName: "lock_open",
          type: EventType.normal,
        ),
        DayEvent(
          id: 15,
          date: day(1),
          time: "14:30",
          title: "Porteira com defeito",
          subtitle: "Motor sem resposta",
          iconName: "warning",
          type: EventType.danger,
        ),
        DayEvent(
          id: 16,
          date: day(1),
          time: "15:10",
          title: "Técnico acionado",
          subtitle: "Manutenção solicitada",
          iconName: "build",
          type: EventType.warning,
        ),
      ],
      key(2): [
        DayEvent(
          id: 11,
          date: day(2),
          time: "07:00",
          title: "Porteira aberta",
          subtitle: "Abertura programada",
          iconName: "lock_open",
          type: EventType.normal,
        ),
        DayEvent(
          id: 12,
          date: day(2),
          time: "10:20",
          title: "Caminhão entrou",
          subtitle: "Veículo de carga detectado",
          iconName: "truck",
          type: EventType.info,
        ),
        DayEvent(
          id: 13,
          date: day(2),
          time: "18:30",
          title: "Fechamento automático",
          subtitle: "Porteira fechada pelo sistema",
          iconName: "lock",
          type: EventType.normal,
        ),
      ],
      key(3): [
        DayEvent(
          id: 7,
          date: day(3),
          time: "07:14",
          title: "Porteira aberta",
          subtitle: "Aberta remotamente",
          iconName: "lock_open",
          type: EventType.normal,
        ),
        DayEvent(
          id: 8,
          date: day(3),
          time: "11:45",
          title: "Falha no sensor",
          subtitle: "Sensor de presença sem resposta",
          iconName: "sensors_off",
          type: EventType.warning,
        ),
        DayEvent(
          id: 9,
          date: day(3),
          time: "11:52",
          title: "Sensor normalizado",
          subtitle: "Sensor voltou a responder",
          iconName: "sensors",
          type: EventType.normal,
        ),
        DayEvent(
          id: 10,
          date: day(3),
          time: "18:44",
          title: "Fechamento automático",
          subtitle: "Porteira fechada pelo sistema",
          iconName: "lock",
          type: EventType.normal,
        ),
      ],
      key(4): [
        DayEvent(
          id: 4,
          date: day(4),
          time: "07:00",
          title: "Porteira aberta",
          subtitle: "Abertura programada",
          iconName: "lock_open",
          type: EventType.normal,
        ),
        DayEvent(
          id: 5,
          date: day(4),
          time: "08:10",
          title: "Carro entrou",
          subtitle: "Veículo detectado na entrada",
          iconName: "car",
          type: EventType.info,
        ),
        DayEvent(
          id: 6,
          date: day(4),
          time: "18:30",
          title: "Fechamento automático",
          subtitle: "Porteira fechada pelo sistema",
          iconName: "lock",
          type: EventType.normal,
        ),
      ],
      key(5): [
        DayEvent(
          id: 1,
          date: day(5),
          time: "06:30",
          title: "Porteira aberta",
          subtitle: "Aberta remotamente",
          iconName: "lock_open",
          type: EventType.normal,
        ),
        DayEvent(
          id: 2,
          date: day(5),
          time: "06:31",
          title: "Maria autorizou acesso",
          subtitle: "Acesso liberado manualmente",
          iconName: "person",
          type: EventType.normal,
        ),
        DayEvent(
          id: 3,
          date: day(5),
          time: "19:00",
          title: "Fechamento automático",
          subtitle: "Porteira fechada pelo sistema",
          iconName: "lock",
          type: EventType.normal,
        ),
      ],
    };
  }

  @override
  Future<List<DayEvent>> getEventsForDate(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _eventsByDay[DateHelper.dateToKey(date)] ?? [];
  }

  @override
  Future<List<DayEvent>> getEventsForDateKey(String dateKey) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _eventsByDay[dateKey] ?? [];
  }
}
