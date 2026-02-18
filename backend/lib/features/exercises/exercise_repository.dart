import 'package:sqlite3/sqlite3.dart';

import '../../core/database/database.dart';

/// Data access layer for the [exercises] table.
class ExerciseRepository {
  const ExerciseRepository(this._db);

  final AppDatabase _db;

  /// Returns all exercises owned by [userId].
  List<Row> findAllByUser(String userId) =>
      _db.db.select(
        'SELECT id, title, description, external_link, image_url, created_at '
        'FROM exercises WHERE user_id = ? ORDER BY created_at ASC',
        [userId],
      );

  /// Returns the exercise with [id] owned by [userId], or `null`.
  Row? findByIdAndUser(String id, String userId) {
    final rows = _db.db.select(
      'SELECT id, title, description, external_link, image_url, created_at '
      'FROM exercises WHERE id = ? AND user_id = ?',
      [id, userId],
    );
    return rows.isEmpty ? null : rows.first;
  }

  /// Inserts a new exercise row.
  void insert({
    required String id,
    required String userId,
    required String title,
    String? description,
    String? externalLink,
    String? imageUrl,
  }) {
    _db.db.execute(
      'INSERT INTO exercises (id, user_id, title, description, external_link, image_url) '
      'VALUES (?, ?, ?, ?, ?, ?)',
      [id, userId, title, description, externalLink, imageUrl],
    );
  }

  /// Replaces all mutable fields for the exercise with [id].
  void update({
    required String id,
    required String title,
    String? description,
    String? externalLink,
    String? imageUrl,
  }) {
    _db.db.execute(
      'UPDATE exercises SET title = ?, description = ?, external_link = ?, image_url = ? '
      'WHERE id = ?',
      [title, description, externalLink, imageUrl, id],
    );
  }

  /// Deletes the exercise with [id].
  void delete(String id) =>
      _db.db.execute('DELETE FROM exercises WHERE id = ?', [id]);
}
