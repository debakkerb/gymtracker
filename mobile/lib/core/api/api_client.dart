import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../auth/token_storage.dart';
import 'api_exception.dart';

/// Base HTTP client that:
/// - Prefixes every request with the API base URL and version path.
/// - Injects the `Authorization: Bearer` header when a token is stored.
/// - Translates HTTP error responses into typed [ApiException]s.
///
/// Use [ApiClient.get], [ApiClient.post], [ApiClient.put], and
/// [ApiClient.delete] in feature-specific remote data sources.
class ApiClient {
  ApiClient({
    required String baseUrl,
    required TokenStorage tokenStorage,
    http.Client? httpClient,
  }) : _base = Uri.parse('$baseUrl/api/v1/'),
       _tokenStorage = tokenStorage,
       _http = httpClient ?? http.Client();

  final Uri _base;
  final TokenStorage _tokenStorage;
  final http.Client _http;

  // ── HTTP verbs ────────────────────────────────────────────────────────────

  Future<dynamic> get(String path) => _send('GET', path);

  Future<dynamic> post(String path, {Object? body}) =>
      _send('POST', path, body: body);

  Future<dynamic> put(String path, {Object? body}) =>
      _send('PUT', path, body: body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  // ── Internals ─────────────────────────────────────────────────────────────

  Future<dynamic> _send(String method, String path, {Object? body}) async {
    final uri = _base.resolve(path.startsWith('/') ? path.substring(1) : path);
    final headers = await _buildHeaders();

    final request = http.Request(method, uri)..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);

    http.StreamedResponse streamed;
    try {
      streamed = await _http.send(request);
    } on SocketException catch (e) {
      throw NetworkException('Could not reach the server: ${e.message}');
    }

    final response = await http.Response.fromStream(streamed);
    return _handleResponse(response);
  }

  Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
    };
    final token = await _tokenStorage.read();
    if (token != null) {
      headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    final body = _decodeBody(response.body);

    return switch (response.statusCode) {
      >= 200 && < 300 => body,
      400 => throw BadRequestException(_errorMessage(body)),
      401 => throw UnauthorisedException(_errorMessage(body)),
      403 => throw ForbiddenException(_errorMessage(body)),
      404 => throw NotFoundException(_errorMessage(body)),
      409 => throw ConflictException(_errorMessage(body)),
      422 => throw ValidationException(_errorMessage(body)),
      _ => throw ServerException(
        'Unexpected response ${response.statusCode}: ${response.body}',
      ),
    };
  }

  static dynamic _decodeBody(String raw) {
    if (raw.isEmpty) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return raw;
    }
  }

  static String _errorMessage(dynamic body) {
    if (body is Map<String, dynamic>) {
      return (body['error'] as String?) ?? body.toString();
    }
    return body?.toString() ?? 'Unknown error';
  }

  void dispose() => _http.close();
}
