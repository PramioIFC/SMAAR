import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Erro de API com a mensagem devolvida pelo backend.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Cliente HTTP singleton — gerencia o token JWT e a URL do servidor automaticamente.
///
/// A URL do servidor é salva no armazenamento seguro do dispositivo.
/// Na primeira vez, o usuário informa o IP na tela de login — nunca mais precisa mudar.
class ApiClient {
  factory ApiClient() => _i;
  static final ApiClient _i = ApiClient._();
  ApiClient._();

  static const _storage = FlutterSecureStorage();
  static const _keyAccess   = 'access_token';
  static const _keyRefresh  = 'refresh_token';
  static const _keyBaseUrl  = 'server_url';
  static const _defaultPort = '8000';

  // ── URL do servidor ────────────────────────────────────────────────────────

  /// Retorna a URL base salva, ou null se ainda não configurada.
  Future<String?> getBaseUrl() => _storage.read(key: _keyBaseUrl);

  /// Salva a URL do servidor (ex: "192.168.1.50" ou "192.168.1.50:8000").
  Future<void> saveBaseUrl(String hostOrUrl) async {
    // Normaliza: aceita "192.168.1.50", "192.168.1.50:8000" ou URL completa
    String url = hostOrUrl.trim();
    if (!url.startsWith('http')) {
      // Só IP/host — adiciona http:// e porta padrão se necessário
      if (!url.contains(':')) url = '$url:$_defaultPort';
      url = 'http://$url';
    }
    if (url.endsWith('/')) url = url.substring(0, url.length - 1);
    await _storage.write(key: _keyBaseUrl, value: '$url/api');
  }

  Future<String> _requireBaseUrl() async {
    final url = await getBaseUrl();
    if (url == null || url.isEmpty) {
      throw const ApiException('Servidor não configurado. Informe o IP na tela de login.');
    }
    return url;
  }

  // ── Tokens ────────────────────────────────────────────────────────────────

  Future<void> saveTokens({required String access, required String refresh}) async {
    await _storage.write(key: _keyAccess,  value: access);
    await _storage.write(key: _keyRefresh, value: refresh);
  }

  Future<String?> get accessToken => _storage.read(key: _keyAccess);

  Future<void> clearTokens() async {
    await _storage.delete(key: _keyAccess);
    await _storage.delete(key: _keyRefresh);
  }

  Future<bool> get isAuthenticated async =>
      (await _storage.read(key: _keyAccess)) != null;

  // ── Headers ───────────────────────────────────────────────────────────────

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final token = await _storage.read(key: _keyAccess);
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Uri> _uri(String path, [Map<String, dynamic>? query]) async {
    final baseUrl = await _requireBaseUrl();
    final clean = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('$baseUrl/$clean').replace(
      queryParameters: query?.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  // ── Processamento da resposta ─────────────────────────────────────────────

  dynamic _process(http.Response res) {
    final isJson = res.headers['content-type']?.contains('application/json') ?? false;
    final body   = (isJson && res.body.isNotEmpty) ? jsonDecode(res.body) : null;

    if (res.statusCode >= 200 && res.statusCode < 300) return body;

    String msg = 'Erro de comunicação com o servidor';
    if (body is Map) {
      msg = (body['erro'] ?? body['detail'] ?? body['mensagem'])?.toString() ?? msg;
    }
    throw ApiException(msg, statusCode: res.statusCode);
  }

  // ── Verbos ────────────────────────────────────────────────────────────────

  Future<dynamic> get(String path, {Map<String, dynamic>? query, bool auth = true}) async {
    final res = await http.get(await _uri(path, query), headers: await _headers(auth: auth));
    return _process(res);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body, bool auth = true}) async {
    final res = await http.post(
      await _uri(path),
      headers: await _headers(auth: auth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _process(res);
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body, bool auth = true}) async {
    final res = await http.patch(
      await _uri(path),
      headers: await _headers(auth: auth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _process(res);
  }

  Future<void> delete(String path) async {
    final res = await http.delete(await _uri(path), headers: await _headers());
    _process(res);
  }
}
