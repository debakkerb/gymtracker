import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/app_config.dart';
import '../../core/database/database.dart';
import '../../core/http/json_response.dart' as r;
import 'auth_repository.dart';

/// Handles all `/api/v1/auth` routes.
///
/// Routes:
/// - `POST /register` — create account, returns token + user
/// - `POST /login`    — authenticate, returns token + user
/// - `POST /logout`   — authenticated; client discards the token
class AuthHandler {
  AuthHandler(this._config, AppDatabase db)
      : _repo = AuthRepository(db);

  final AppConfig _config;
  final AuthRepository _repo;

  static const _uuid = Uuid();

  /// `POST /api/v1/auth/register`
  Future<Response> register(Request request) async {
    final body = await _parseJson(request);
    if (body == null) return r.badRequest('Request body must be valid JSON');

    final email = (body['email'] as String?)?.trim().toLowerCase();
    final password = body['password'] as String?;
    final dateOfBirth = body['date_of_birth'] as String?;

    if (email == null || email.isEmpty) {
      return r.unprocessable('email is required');
    }
    if (!_emailRegex.hasMatch(email)) {
      return r.unprocessable('email is not valid');
    }
    if (password == null || password.length < 8) {
      return r.unprocessable('password must be at least 8 characters');
    }

    if (_repo.findByEmail(email) != null) {
      return r.conflict('An account with this email already exists');
    }

    final id = _uuid.v4();
    final hash = BCrypt.hashpw(password, BCrypt.gensalt());
    _repo.insert(
      id: id,
      email: email,
      passwordHash: hash,
      dateOfBirth: dateOfBirth,
    );

    final token = _issueToken(id);
    return r.created({
      'token': token,
      'user': {'id': id, 'email': email, 'date_of_birth': dateOfBirth},
    });
  }

  /// `POST /api/v1/auth/login`
  Future<Response> login(Request request) async {
    final body = await _parseJson(request);
    if (body == null) return r.badRequest('Request body must be valid JSON');

    final email = (body['email'] as String?)?.trim().toLowerCase();
    final password = body['password'] as String?;

    if (email == null || password == null) {
      return r.unprocessable('email and password are required');
    }

    final user = _repo.findByEmail(email);
    // Use the same message for both "not found" and "wrong password" to
    // avoid leaking account existence.
    if (user == null ||
        !BCrypt.checkpw(password, user['password_hash'] as String)) {
      return r.unauthorized('Invalid email or password');
    }

    final id = user['id'] as String;
    final token = _issueToken(id);
    return r.ok({
      'token': token,
      'user': {
        'id': id,
        'email': user['email'],
        'date_of_birth': user['date_of_birth'],
      },
    });
  }

  /// `POST /api/v1/auth/logout`
  ///
  /// The server is stateless (JWT). This endpoint exists so the client has a
  /// consistent logout URL; the actual token is discarded client-side.
  /// A server-side blocklist can be added here in the future.
  Response logout(Request request) {
    return r.ok({'message': 'Logged out successfully'});
  }

  String _issueToken(String userId) {
    return JWT({'sub': userId}, issuer: 'gymtracker').sign(
      SecretKey(_config.jwtSecret),
      expiresIn: Duration(hours: _config.jwtExpiryHours),
    );
  }

  static final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  static Future<Map<String, dynamic>?> _parseJson(Request request) async {
    try {
      return jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
