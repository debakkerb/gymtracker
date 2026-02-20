import 'package:sqlite3/sqlite3.dart';

import '../../core/database/database.dart';

/// Data access layer for the [sessions] and [session_exercises] tables.
class SessionRepository {
  const SessionRepository(this._db);

  final AppDatabase _db;

  /// Returns all sessions owned by [userId], newest first.
  List<Row> findAllByUser(String userId) => _db.db.select(
        'SELECT id, workout_title, date, duration_seconds, created_at '
        'FROM sessions WHERE user_id = ? ORDER BY date DESC',
        [userId],
      );

  /// Returns the ordered exercise records for [sessionId].
  List<Row> findExercises(String sessionId) => _db.db.select(
        'SELECT id, exercise_name, repetitions, series, sort_order '
        'FROM session_exercises WHERE session_id = ? ORDER BY sort_order ASC',
        [sessionId],
      );

  /// Inserts a session and its exercise snapshots atomically.
  void insert({
    required String id,
    required String userId,
    required String workoutTitle,
    required String date,
    required int durationSeconds,
    required List<Map<String, dynamic>> exercises,
  }) {
    _db.db.execute(
      'INSERT INTO sessions (id, user_id, workout_title, date, duration_seconds) '
      'VALUES (?, ?, ?, ?, ?)',
      [id, userId, workoutTitle, date, durationSeconds],
    );

    for (var i = 0; i < exercises.length; i++) {
      final ex = exercises[i];
      _db.db.execute(
        'INSERT INTO session_exercises '
        '(id, session_id, exercise_name, repetitions, series, sort_order) '
        'VALUES (?, ?, ?, ?, ?, ?)',
        [
          '${id}_$i',
          id,
          ex['exercise_name'],
          ex['repetitions'],
          ex['series'],
          i,
        ],
      );
    }
  }
}
