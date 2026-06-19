import 'dart:convert';
import 'package:http/http.dart' as http;

class UsuarioDao {
  static const String baseUrl = 'http://10.0.2.2:8000/api'; // ajuste conforme seu ambiente

  Future<http.Response> registrar(String username, String password) {
    return http.post(
      Uri.parse('$baseUrl/registro/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'confirmar_senha': password, // confirmação já validada na tela antes de chamar
      }),
    );
  }

  Future<http.Response> login(String username, String password) {
    return http.post(
      Uri.parse('$baseUrl/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
  }
}