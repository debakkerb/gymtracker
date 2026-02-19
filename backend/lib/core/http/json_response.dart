import 'dart:convert';

import 'package:shelf/shelf.dart';

const _jsonHeader = {'content-type': 'application/json'};

/// 200 OK with a JSON body.
Response ok(Object data) => Response.ok(jsonEncode(data), headers: _jsonHeader);

/// 201 Created with a JSON body.
Response created(Object data) =>
    Response(201, body: jsonEncode(data), headers: _jsonHeader);

/// 400 Bad Request.
Response badRequest(String message) => _error(400, message);

/// 401 Unauthorized.
Response unauthorized(String message) => _error(401, message);

/// 403 Forbidden.
Response forbidden(String message) => _error(403, message);

/// 404 Not Found.
Response notFound(String message) => _error(404, message);

/// 409 Conflict.
Response conflict(String message) => _error(409, message);

/// 422 Unprocessable Entity — used for validation failures.
Response unprocessable(String message) => _error(422, message);

/// 500 Internal Server Error.
Response serverError(String message) => _error(500, message);

Response _error(int status, String message) => Response(
      status,
      body: jsonEncode({'error': message}),
      headers: _jsonHeader,
    );
