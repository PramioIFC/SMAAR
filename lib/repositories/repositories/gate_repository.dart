import '/models/models.dart';

/// Repository para gerenciar dados de Porteiras
/// Atualmente usa dados mock, preparado para PostgreSQL
abstract class GateRepository {
  Future<List<Gate>> getAllGates();
  Future<Gate?> getGateById(int id);
  Future<Gate?> getGateByName(String name);
  Future<void> updateGateStatus(int id, bool isClosed);
}

/// Implementação mock do GateRepository
/// Substituir por implementação PostgreSQL quando integrar
class MockGateRepository implements GateRepository {
  // Dados mock
  final List<Gate> _gates = [
    const Gate(
      id: 1,
      name: "Porteira 1",
      limitTimeStart: "6:00",
      limitTimeEnd: "23:00",
      isClosed: true,
      lastActivityDescription: "Fechada corretamente",
    ),
    const Gate(
      id: 2,
      name: "Porteira 2",
      limitTimeStart: "9:00",
      limitTimeEnd: "22:00",
      isClosed: false,
      lastActivityDescription: "Aberta manualmente",
    ),
    const Gate(
      id: 3,
      name: "Porteira 3",
      limitTimeStart: "9:00",
      limitTimeEnd: "22:00",
      isClosed: true,
      lastActivityDescription: "Fechamento automático",
    ),
  ];

  @override
  Future<List<Gate>> getAllGates() async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_gates);
  }

  @override
  Future<Gate?> getGateById(int id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _gates.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Gate?> getGateByName(String name) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _gates.firstWhere((g) => g.name == name);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateGateStatus(int id, bool isClosed) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _gates.indexWhere((g) => g.id == id);
    if (index != -1) {
      _gates[index] = _gates[index].copyWith(isClosed: isClosed);
    }
  }
}
