import 'package:flutter/foundation.dart';

import '../domain/user.dart';

/// In-memory storage for registered users and auth state.
///
/// Exposes [ValueNotifier]s so the UI can rebuild reactively
/// whenever the list or current user changes.
class AuthRepository {
  final _users = ValueNotifier<List<User>>([]);
  final _currentUser = ValueNotifier<User?>(null);

  /// A listenable snapshot of all registered users.
  ValueListenable<List<User>> get users => _users;

  /// The currently logged-in user, or `null` if no one is signed in.
  ValueListenable<User?> get currentUser => _currentUser;

  /// Adds [user] to the store and notifies listeners.
  void add(User user) {
    _users.value = [..._users.value, user];
  }

  /// Returns the user with [email] (case-insensitive), or `null`.
  User? findByEmail(String email) {
    final lower = email.toLowerCase();
    for (final user in _users.value) {
      if (user.email == lower) return user;
    }
    return null;
  }

  /// Attempts to log in with [email] and [password].
  ///
  /// Returns `null` on success, or an error message on failure.
  String? login(String email, String password) {
    final user = findByEmail(email);
    if (user == null) return 'No account found with that email';
    if (user.password != password) return 'Incorrect password';
    _currentUser.value = user;
    return null;
  }

  /// Logs out the current user.
  void logout() {
    _currentUser.value = null;
  }
}
