import 'package:sqlite3/sqlite3.dart';

import '../../core/database/database.dart';

/// Data access layer for the [users] table.
class AuthRepository {
  const AuthRepository(this._db);

  final AppDatabase _db;

  /// Returns the user row for [email] (case-insensitive), or `null`.
  Row? findByEmail(String email) {
    final rows = _db.db.select(
      'SELECT id, email, password_hash, date_of_birth FROM users '
      'WHERE email = ?',
      [email.toLowerCase()],
    );
    return rows.isEmpty ? null : rows.first;
  }

  /// Returns the user row for [id], or `null`.
  Row? findById(String id) {
    final rows = _db.db.select(
      'SELECT id, email, date_of_birth FROM users WHERE id = ?',
      [id],
    );
    return rows.isEmpty ? null : rows.first;
  }

  /// Inserts a new user and returns the created row.
  void insert({
    required String id,
    required String email,
    required String passwordHash,
    String? dateOfBirth,
  }) {
    _db.db.execute(
      'INSERT INTO users (id, email, password_hash, date_of_birth) '
      'VALUES (?, ?, ?, ?)',
      [id, email.toLowerCase(), passwordHash, dateOfBirth],
    );
  }
}
