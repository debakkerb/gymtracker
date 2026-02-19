import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the JWT access token in the platform's secure storage.
///
/// On iOS this uses Keychain, on Android EncryptedSharedPreferences,
/// and on Web localStorage (acceptable for development; consider a
/// HttpOnly cookie approach for a production web deployment).
class TokenStorage {
  const TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _key = 'auth_token';

  /// Returns the stored token, or `null` if none is saved.
  Future<String?> read() => _storage.read(key: _key);

  /// Persists [token].
  Future<void> write(String token) => _storage.write(key: _key, value: token);

  /// Removes the stored token (e.g., on logout).
  Future<void> delete() => _storage.delete(key: _key);
}
