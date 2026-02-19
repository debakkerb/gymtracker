import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';

import '../config/app_config.dart';
import '../http/json_response.dart' as r;

/// Verifies the `Authorization: Bearer <token>` header on every request.
///
/// On success, the authenticated user's ID is added to the request context
/// under the key `'userId'`. Handlers can read it via [RequestAuth.userId].
///
/// On failure, returns 401 before the inner handler is called.
Middleware authMiddleware(AppConfig config) {
  return (Handler inner) => (Request request) {
        final authHeader = request.headers['authorization'] ?? '';
        if (!authHeader.startsWith('Bearer ')) {
          return r.unauthorized(
            'Missing or invalid Authorization header. '
            'Expected: Authorization: Bearer <token>',
          );
        }

        final token = authHeader.substring(7);
        try {
          final jwt = JWT.verify(token, SecretKey(config.jwtSecret));
          final payload = jwt.payload as Map<String, dynamic>;
          final userId = payload['sub'] as String?;
          if (userId == null) return r.unauthorized('Token missing subject');
          return inner(request.change(context: {'userId': userId}));
        } on JWTExpiredException {
          return r.unauthorized('Token has expired');
        } on JWTException catch (e) {
          return r.unauthorized('Invalid token: ${e.message}');
        }
      };
}

/// Convenience extension so handlers can read the authenticated user ID
/// without casting manually.
extension RequestAuth on Request {
  /// The authenticated user's ID, set by [authMiddleware].
  ///
  /// Only valid inside a handler that is wrapped by [authMiddleware].
  String get userId => context['userId'] as String;
}
