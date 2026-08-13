import 'dart:async';
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
class ApiClient {
  factory ApiClient() => _i;
  static final ApiClient _i = ApiClient._();
  ApiClient._();

  static const _storage       = FlutterSecureStorage();
  static const _keyAccess     = 'access_token';
  static const _keyRefresh    = 'refresh_token';
  static const _keyBaseUrl    = 'server_url';
  static const _defaultPort   = '8000';
  static const _timeout        = Duration(seconds: 15);

  // ── URL do servidor ───────────────────────────────────────────────────────

  Future<String?> getBaseUrl() => _storage.read(key: _keyBaseUrl);

  Future<void> saveBaseUrl(String hostOrUrl) async {
    String url = hostOrUrl.trim();
    if (!url.startsWith('http')) {
      if (!url.contains(':')) url = '$url:$_defaultPort';
      url = 'http://$url';
    }
    if (url.endsWith('/')) url = url.substring(0, url.length - 1);
    await _storage.write(key: _keyBaseUrl, value: '$url/api');
  }

  Future<String> _requireBaseUrl() async {
    final url = await getBaseUrl();
    if (url == null || url.isEmpty) {
      throw const ApiException(
        'Servidor não configurado. Informe o IP na tela de login.',
      );
    }
    return url;
  }

  // ── Tokens ────────────────────────────────────────────────────────────────

  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
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
    // Ngrok free tier retorna uma página HTML de aviso ao invés de JSON
    // sem este header — necessário em TODAS as requisições para o túnel.
    final baseUrl = await _storage.read(key: _keyBaseUrl) ?? '';
    if (baseUrl.contains('ngrok')) {
      headers['ngrok-skip-browser-warning'] = 'true';
    }
    return headers;
  }

  Future<Uri> _uri(String path, [Map<String, dynamic>? query]) async {
    final baseUrl = await _requireBaseUrl();
    final clean   = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('$baseUrl/$clean').replace(
      queryParameters: query?.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  // ── Processamento da resposta ─────────────────────────────────────────────

  dynamic _process(http.Response res) {
    final isJson =
        res.headers['content-type']?.contains('application/json') ?? false;
    final body = (isJson && res.body.isNotEmpty) ? jsonDecode(res.body) : null;

    if (res.statusCode >= 200 && res.statusCode < 300) return body;

    String msg = 'Erro de comunicação com o servidor';
    if (body is Map) {
      msg = (body['erro'] ?? body['detail'] ?? body['mensagem'])?.toString() ?? msg;
    }
    throw ApiException(msg, statusCode: res.statusCode);
  }

  // ── Verbos (todos com timeout de 5s) ───────────────────────────────────────

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    bool auth = true,
  }) async {
    try {
      final res = await http.get(
        await _uri(path, query),
        headers: await _headers(auth: auth),
      ).timeout(_timeout);
      return _process(res);
    } on TimeoutException {
      throw const ApiException('Servidor não respondeu a tempo.', statusCode: 408);
    }
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    try {
      final res = await http.post(
        await _uri(path),
        headers: await _headers(auth: auth),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(_timeout);
      return _process(res);
    } on TimeoutException {
      throw const ApiException('Servidor não respondeu a tempo.', statusCode: 408);
    }
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    try {
      final res = await http.put(
        await _uri(path),
        headers: await _headers(auth: auth),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(_timeout);
      return _process(res);
    } on TimeoutException {
      throw const ApiException('Servidor não respondeu a tempo.', statusCode: 408);
    }
  }

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    try {
      final res = await http.patch(
        await _uri(path),
        headers: await _headers(auth: auth),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(_timeout);
      return _process(res);
    } on TimeoutException {
      throw const ApiException('Servidor não respondeu a tempo.', statusCode: 408);
    }
  }

  Future<void> delete(String path) async {
    try {
      final res = await http.delete(
        await _uri(path),
        headers: await _headers(),
      ).timeout(_timeout);
      _process(res);
    } on TimeoutException {
      throw const ApiException('Servidor não respondeu a tempo.', statusCode: 408);
    }
  }

  // ── Arduino ───────────────────────────────────────────────────────────────

  Future<bool> enviarComandoArduino(String comando) async {
    try {
      await post('/arduino/comando/', body: {'comando': comando});
      return true;
    } catch (_) {
      return false;
    }
  }

  // [CORRIGIDO] Era patch() — backend só aceita PUT em /arduino/config/
  Future<void> salvarIpArduino(String ip, {int porta = 80}) async {
    await put('/arduino/config/', body: {'ip': ip, 'porta': porta});
  }

  Future<Map<String, dynamic>?> buscarConfigArduino() async {
    try {
      final data = await get('/arduino/config/');
      return data as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }
}
