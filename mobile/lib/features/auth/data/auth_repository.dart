import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/auth/token_storage.dart';
import '../domain/user.dart';

/// Manages authentication state and communicates with the auth API.
///
/// Call [init] once on app startup to restore any persisted session without
/// a network round-trip. The [currentUser] listenable drives GoRouter's
/// redirect guard, so any change automatically triggers a navigation update.
class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  }) : _api = apiClient,
       _tokenStorage = tokenStorage;

  final ApiClient _api;
  final TokenStorage _tokenStorage;
  final _currentUser = ValueNotifier<User?>(null);

  /// The currently authenticated user, or `null` when signed out.
  ValueListenable<User?> get currentUser => _currentUser;

  /// Restores a persisted session on app startup.
  ///
  /// Reads token and cached user data from secure storage. If both are
  /// present the session is restored immediately, with no network call.
  Future<void> init() async {
    final token = await _tokenStorage.read();
    if (token == null) return;
    final userData = await _tokenStorage.readUser();
    if (userData != null) {
      _currentUser.value = User.fromJson(userData);
    }
  }

  /// Authenticates with [email] and [password].
  ///
  /// Persists the returned token and user, then sets [currentUser].
  /// Throws an [ApiException] subtype on failure (wrong credentials,
  /// network error, etc.) so the caller can surface the right message.
  Future<void> login(String email, String password) async {
    final data =
        await _api.post(
              '/auth/login',
              body: {'email': email, 'password': password},
            )
            as Map<String, dynamic>;
    await _persist(data);
  }

  /// Creates a new account and immediately signs in.
  ///
  /// The backend returns a token on successful registration, so the user
  /// lands on the home screen without a separate login step.
  /// Throws an [ApiException] subtype on failure (duplicate email, etc.).
  Future<void> register(
    String email,
    String password, {
    DateTime? dateOfBirth,
  }) async {
    final data =
        await _api.post(
              '/auth/register',
              body: {
                'email': email,
                'password': password,
                if (dateOfBirth != null)
                  'date_of_birth': dateOfBirth
                      .toIso8601String()
                      .split('T')
                      .first,
              },
            )
            as Map<String, dynamic>;
    await _persist(data);
  }

  /// Signs out the current user and clears all local session data.
  ///
  /// The server call is best-effort: local state is always cleared even
  /// if the network request fails.
  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {
      // Intentionally swallowed — local state is cleared regardless.
    } finally {
      await _tokenStorage.clear();
      _currentUser.value = null;
    }
  }

  Future<void> _persist(Map<String, dynamic> data) async {
    final token = data['token'] as String;
    final userData = data['user'] as Map<String, dynamic>;
    await _tokenStorage.write(token);
    await _tokenStorage.writeUser(userData);
    _currentUser.value = User.fromJson(userData);
  }
}
