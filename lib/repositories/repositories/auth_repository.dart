import '../../models/models.dart';
import '../../services/api_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONTRATO
// ─────────────────────────────────────────────────────────────────────────────

abstract class AuthRepository {
  Future<AuthResult> login(String name, String password);
  Future<AuthResult> register(String name, String password);
}

// ─────────────────────────────────────────────────────────────────────────────
// IMPLEMENTAÇÃO REAL — Django REST + JWT
// ─────────────────────────────────────────────────────────────────────────────

class ApiAuthRepository implements AuthRepository {
  final _client = ApiClient();

  @override
  Future<AuthResult> login(String name, String password) async {
    try {
      final data = await _client.post(
        '/login/',
        body: {'username': name.trim(), 'password': password},
        auth: false,
      );

      await _client.saveTokens(
        access:  data['access']  as String,
        refresh: data['refresh'] as String,
      );

      return AuthResult(
        status: AuthStatus.success,
        user: User(id: data['id'] as int, name: data['username'] as String),
      );
    } on ApiException catch (e) {
      if (e.statusCode == 401) return const AuthResult(status: AuthStatus.invalidCredentials);
      // Mostra a mensagem real do servidor (ex: "Servidor não respondeu a tempo")
      return AuthResult(status: AuthStatus.unknownError, rawMessage: e.message);
    } catch (e) {
      // Mostra o erro real (ex: SocketException, FormatException, etc.)
      return AuthResult(status: AuthStatus.unknownError, rawMessage: e.toString());
    }
  }

  @override
  Future<AuthResult> register(String name, String password) async {
    try {
      final data = await _client.post(
        '/registro/',
        body: {
          'username': name.trim(),
          'password': password,
          'confirmar_senha': password,
        },
        auth: false,
      );

      // O backend retorna tokens já no cadastro — o usuário fica logado
      await _client.saveTokens(
        access:  data['access']  as String,
        refresh: data['refresh'] as String,
      );

      return AuthResult(
        status: AuthStatus.success,
        user: User(id: data['id'] as int, name: data['username'] as String),
      );
    } on ApiException catch (e) {
      if (e.message.toLowerCase().contains('já existe')) {
        return const AuthResult(status: AuthStatus.userAlreadyExists);
      }
      return AuthResult(status: AuthStatus.unknownError, rawMessage: e.message);
    } catch (e) {
      return AuthResult(status: AuthStatus.unknownError, rawMessage: e.toString());
    }
  }
}
