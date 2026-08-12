import '../../models/models.dart';
import '../../services/api_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONTRATO
// ─────────────────────────────────────────────────────────────────────────────

abstract class GateRepository {
  Future<List<Gate>> getGatesForUser(int userId);
  Future<Gate> createGate(Gate gate, {required int ownerId});
  Future<Gate> updateGate(Gate gate);
  Future<DayEvent> updateGateStatus(int id, bool isClosed);
  Future<void> deleteGate(int id);
  Future<List<DayEvent>> getRegistrosForGate(int gateId);
  Future<Map<String, String>> getCalendarioForGate(int gateId, {required int year, required int month});
}

// ─────────────────────────────────────────────────────────────────────────────
// IMPLEMENTAÇÃO REAL — Django REST + JWT
// ─────────────────────────────────────────────────────────────────────────────

class ApiGateRepository implements GateRepository {
  final _client = ApiClient();

  @override
  Future<List<Gate>> getGatesForUser(int userId) async {
    // O backend filtra pelo usuário autenticado via JWT; userId é ignorado.
    final list = await _client.get('/porteiras/') as List<dynamic>;
    return list.map((j) => Gate.fromApiJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<Gate> createGate(Gate gate, {required int ownerId}) async {
    final data = await _client.post('/porteiras/', body: gate.toCreateJson());
    return Gate.fromApiJson(data as Map<String, dynamic>);
  }

  @override
  Future<Gate> updateGate(Gate gate) async {
    final data = await _client.put('/porteiras/${gate.id}/', body: gate.toCreateJson());
    return Gate.fromApiJson(data as Map<String, dynamic>);
  }

  @override
  Future<DayEvent> updateGateStatus(int id, bool isClosed) async {
    final acao = isClosed ? 'fechar' : 'abrir';
    final data = await _client.post('/porteiras/$id/$acao/');
    return DayEvent.fromRegistroJson(data['registro'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteGate(int id) => _client.delete('/porteiras/$id/');

  @override
  Future<List<DayEvent>> getRegistrosForGate(int gateId) async {
    final list = await _client.get('/porteiras/$gateId/registros/') as List<dynamic>;
    return list.map((j) => DayEvent.fromRegistroJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<Map<String, String>> getCalendarioForGate(
    int gateId, {required int year, required int month}
  ) async {
    final data = await _client.get(
      '/porteiras/$gateId/calendario/',
      query: {'ano': year, 'mes': month},
    ) as Map<String, dynamic>;
    return data.map((k, v) => MapEntry(k, v as String));
  }
}
