import '../../models/models.dart';

// =============================================================================
// CONTRATO — não muda quando o banco chegar
// =============================================================================

/// Repositório de porteiras.
///
/// Hoje: [MockGateRepository] (memória, singleton).
/// Depois: crie [PostgresGateRepository] implementando este contrato
/// e troque a linha no main.dart — o resto do app não muda.
abstract class GateRepository {
  /// Retorna todas as porteiras do usuário com [userId].
  ///
  /// PostgreSQL:
  ///   SELECT * FROM gates WHERE owner_id = @userId ORDER BY id;
  Future<List<Gate>> getGatesForUser(int userId);

  /// Persiste uma nova porteira e retorna o objeto com o id atribuído.
  ///
  /// PostgreSQL:
  ///   INSERT INTO gates (name, limit_time_start, limit_time_end, is_closed, owner_id)
  ///   VALUES (@name, @start, @end, @isClosed, @ownerId)
  ///   RETURNING *;
  Future<Gate> createGate(Gate gate, {required int ownerId});

  /// Atualiza o status (aberta/fechada) de uma porteira.
  ///
  /// PostgreSQL:
  ///   UPDATE gates SET is_closed = @isClosed WHERE id = @id;
  Future<void> updateGateStatus(int id, bool isClosed);

  /// Remove uma porteira pelo id.
  ///
  /// PostgreSQL:
  ///   DELETE FROM gates WHERE id = @id;
  Future<void> deleteGate(int id);
}

// =============================================================================
// IMPLEMENTAÇÃO MOCK — memória, singleton
// =============================================================================

/// Implementação em memória do [GateRepository].
///
/// Usa singleton para que todas as partes do app (e múltiplos logins
/// durante a mesma sessão do app) compartilhem a mesma lista de porteiras.
///
/// ⚠️  Os dados vivem apenas enquanto o processo estiver ativo.
///     Ao trocar para [PostgresGateRepository] a persistência será real.
class MockGateRepository implements GateRepository {
  // ── Singleton ────────────────────────────────────────────────────────────
  factory MockGateRepository() => _instance;
  static final MockGateRepository _instance = MockGateRepository._internal();
  MockGateRepository._internal();

  // ── "Tabela" em memória ──────────────────────────────────────────────────
  //
  // Simula: CREATE TABLE gates (
  //   id            SERIAL PRIMARY KEY,
  //   name          TEXT NOT NULL,
  //   limit_time_start TEXT NOT NULL,
  //   limit_time_end   TEXT NOT NULL,
  //   is_closed     BOOLEAN NOT NULL DEFAULT TRUE,
  //   owner_id      INTEGER REFERENCES users(id)
  // );
  final List<_GateRow> _rows = [
    _GateRow(
      gate: const Gate(
        id: 1,
        name: 'Porteira 1',
        limitTimeStart: '06:00',
        limitTimeEnd: '23:00',
        isClosed: true,
      ),
      ownerId: 1, // admin
    ),
    _GateRow(
      gate: const Gate(
        id: 2,
        name: 'Porteira 2',
        limitTimeStart: '09:00',
        limitTimeEnd: '22:00',
        isClosed: false,
      ),
      ownerId: 1,
    ),
    _GateRow(
      gate: const Gate(
        id: 3,
        name: 'Porteira 3',
        limitTimeStart: '09:00',
        limitTimeEnd: '22:00',
        isClosed: true,
      ),
      ownerId: 1,
    ),
  ];

  // Simula SERIAL / AUTO_INCREMENT
  int _nextId = 4;

  // ── Contrato ─────────────────────────────────────────────────────────────

  @override
  Future<List<Gate>> getGatesForUser(int userId) async {
    // PostgreSQL → SELECT * FROM gates WHERE owner_id = @userId ORDER BY id;
    await Future.delayed(const Duration(milliseconds: 80));
    return _rows
        .where((r) => r.ownerId == userId)
        .map((r) => r.gate)
        .toList();
  }

  @override
  Future<Gate> createGate(Gate gate, {required int ownerId}) async {
    // PostgreSQL → INSERT INTO gates (...) VALUES (...) RETURNING *;
    await Future.delayed(const Duration(milliseconds: 120));

    // Atribui um id sequencial (o banco faria isso via SERIAL)
    final persisted = gate.copyWith(id: _nextId++);
    _rows.add(_GateRow(gate: persisted, ownerId: ownerId));
    return persisted;
  }

  @override
  Future<void> updateGateStatus(int id, bool isClosed) async {
    // PostgreSQL → UPDATE gates SET is_closed = @isClosed WHERE id = @id;
    await Future.delayed(const Duration(milliseconds: 80));
    final idx = _rows.indexWhere((r) => r.gate.id == id);
    if (idx != -1) {
      _rows[idx] = _GateRow(
        gate: _rows[idx].gate.copyWith(isClosed: isClosed),
        ownerId: _rows[idx].ownerId,
      );
    }
  }

  @override
  Future<void> deleteGate(int id) async {
    // PostgreSQL → DELETE FROM gates WHERE id = @id;
    await Future.delayed(const Duration(milliseconds: 80));
    _rows.removeWhere((r) => r.gate.id == id);
  }

  // ── Helper interno ────────────────────────────────────────────────────────

  /// Retorna os ids das porteiras de [userId] — usado pelo AppStateData
  /// para popular [ownedGateIds] sem expor a estrutura interna.
  List<int> ownedGateIdsForUser(int userId) =>
      _rows.where((r) => r.ownerId == userId).map((r) => r.gate.id!).toList();
}

// Linha interna que associa Gate ↔ owner_id
// (equivale a uma linha da tabela `gates` com a FK)
class _GateRow {
  final Gate gate;
  final int ownerId;
  const _GateRow({required this.gate, required this.ownerId});
}

// =============================================================================
// STUB PARA INTEGRAÇÃO FUTURA — PostgreSQL
// =============================================================================

// Quando o banco estiver pronto, descomente e implemente esta classe.
// Depois troque MockGateRepository por PostgresGateRepository no main.dart.
//
// class PostgresGateRepository implements GateRepository {
//   final SomeDbConnection _db;
//   PostgresGateRepository(this._db);
//
//   @override
//   Future<List<Gate>> getGatesForUser(int userId) async {
//     final rows = await _db.query(
//       'SELECT * FROM gates WHERE owner_id = @userId ORDER BY id',
//       substitutionValues: {'userId': userId},
//     );
//     return rows.map((r) => Gate.fromMap(r.toColumnMap())).toList();
//   }
//
//   @override
//   Future<Gate> createGate(Gate gate, {required int ownerId}) async {
//     final rows = await _db.query(
//       '''INSERT INTO gates (name, limit_time_start, limit_time_end, is_closed, owner_id)
//          VALUES (@name, @start, @end, @isClosed, @ownerId) RETURNING *''',
//       substitutionValues: {
//         'name':     gate.name,
//         'start':    gate.limitTimeStart,
//         'end':      gate.limitTimeEnd,
//         'isClosed': gate.isClosed,
//         'ownerId':  ownerId,
//       },
//     );
//     return Gate.fromMap(rows.first.toColumnMap());
//   }
//
//   @override
//   Future<void> updateGateStatus(int id, bool isClosed) async {
//     await _db.query(
//       'UPDATE gates SET is_closed = @isClosed WHERE id = @id',
//       substitutionValues: {'isClosed': isClosed, 'id': id},
//     );
//   }
//
//   @override
//   Future<void> deleteGate(int id) async {
//     await _db.query(
//       'DELETE FROM gates WHERE id = @id',
//       substitutionValues: {'id': id},
//     );
//   }
// }
