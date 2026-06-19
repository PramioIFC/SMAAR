import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/models.dart';
import '../../dao/usuario_dao.dart';

class ApiAuthRepository implements AuthRepository {
  final UsuarioDao _dao = UsuarioDao();
  final _storage = const FlutterSecureStorage();

  @override
  Future<AuthResult> login(String name, String password) async {
    try {
      final response = await _dao.login(name, password);
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        await _storage.write(key: 'access_token', value: data['access']);
        await _storage.write(key: 'refresh_token', value: data['refresh']);

        final user = User(id: data['id'] as int?, name: data['username'] as String);
        return AuthResult(status: AuthStatus.success, user: user);
      }

      if (response.statusCode == 401) {
        return const AuthResult(status: AuthStatus.invalidCredentials);
      }

      return const AuthResult(status: AuthStatus.unknownError);
    } catch (_) {
      return const AuthResult(status: AuthStatus.unknownError);
    }
  }

  @override
  Future<AuthResult> register(String name, String password) async {
    try {
      final response = await _dao.registrar(name, password);
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201) {
        final user = User(id: data['id'] as int?, name: data['username'] as String);
        return AuthResult(status: AuthStatus.success, user: user);
      }

      if (response.statusCode == 400 && data['erro'] == 'Usuário já existe') {
        return const AuthResult(status: AuthStatus.userAlreadyExists);
      }

      return const AuthResult(status: AuthStatus.unknownError);
    } catch (_) {
      return const AuthResult(status: AuthStatus.unknownError);
    }
  }
}

/// Função de hash mock — retorna 'mock_hash_<senha>'.
/// Substituir por bcrypt/argon2 na integração com PostgreSQL.
String _hashPassword(String password) => 'mock_hash_$password';

bool _checkPassword(String plainPassword, String storedHash) =>
    _hashPassword(plainPassword) == storedHash;

// ─────────────────────────────────────────────────────────────────────────────

/// Contrato do repositório de autenticação.
abstract class AuthRepository {
  /// Autentica um usuário pelo nome e senha.
  Future<AuthResult> login(String name, String password);

  /// Registra um novo usuário.
  /// Retorna [AuthStatus.userAlreadyExists] se o nome já estiver em uso.
  Future<AuthResult> register(String name, String password);
}

// ─────────────────────────────────────────────────────────────────────────────

/// Implementação mock — substituir por PostgreSQL quando integrar.
class MockAuthRepository implements AuthRepository {
  // Singleton: garante que LoginPage e RegisterUserPage compartilhem
  // a mesma lista de usuários em memória.
  factory MockAuthRepository() => _instance;
  static final MockAuthRepository _instance = MockAuthRepository._internal();
  MockAuthRepository._internal();

  /// Simula a tabela `users` do banco.
  final List<User> _users = [
    User(
      id: 1,
      name: 'admin',
      passwordHash: _hashPassword('1234'), // senha: 1234
      ownedGateIds: const [1, 2, 3],
    ),
  ];

  int _nextId = 2;

  // ── Contrato ───────────────────────────────────────────────────────────────

  @override
  Future<AuthResult> login(String name, String password) async {
    await Future.delayed(const Duration(milliseconds: 700));

    try {
      final user = _users.firstWhere(
        (u) => u.name.toLowerCase() == name.trim().toLowerCase(),
      );

      if (!_checkPassword(password, user.passwordHash)) {
        return const AuthResult(status: AuthStatus.invalidCredentials);
      }

      return AuthResult(status: AuthStatus.success, user: user);
    } catch (_) {
      // firstWhere lança StateError quando não encontra
      return const AuthResult(status: AuthStatus.userNotFound);
    }
  }

  @override
  Future<AuthResult> register(String name, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final trimmed = name.trim();

    final exists = _users.any(
      (u) => u.name.toLowerCase() == trimmed.toLowerCase(),
    );

    if (exists) {
      return const AuthResult(status: AuthStatus.userAlreadyExists);
    }

    final newUser = User(
      id: _nextId++,
      name: trimmed,
      passwordHash: _hashPassword(password),
      ownedGateIds: const [], // novo usuário começa sem porteiras
      createdAt: DateTime.now(),
    );

    _users.add(newUser);

    return AuthResult(status: AuthStatus.success, user: newUser);
  }
}
