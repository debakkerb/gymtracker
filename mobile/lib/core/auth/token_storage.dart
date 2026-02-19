import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the JWT access token and cached user data in the platform's
/// secure storage.
///
/// On iOS this uses Keychain, on Android EncryptedSharedPreferences,
/// and on Web localStorage (acceptable for development; consider an
/// HttpOnly cookie approach for a production web deployment).
class TokenStorage {
  const TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  /// Returns the stored JWT, or `null` if no session exists.
  Future<String?> read() => _storage.read(key: _tokenKey);

  /// Persists [token].
  Future<void> write(String token) =>
      _storage.write(key: _tokenKey, value: token);

  /// Removes the stored token.
  Future<void> delete() => _storage.delete(key: _tokenKey);

  /// Returns the cached user payload, or `null` if none is stored.
  Future<Map<String, dynamic>?> readUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  /// Persists [user] as JSON so the session can be restored on next launch.
  Future<void> writeUser(Map<String, dynamic> user) =>
      _storage.write(key: _userKey, value: jsonEncode(user));

  /// Removes the cached user payload.
  Future<void> deleteUser() => _storage.delete(key: _userKey);

  /// Clears all stored auth data (token + user).
  Future<void> clear() async {
    await delete();
    await deleteUser();
  }
}
