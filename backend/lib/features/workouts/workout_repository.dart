import 'package:sqlite3/sqlite3.dart';

import '../../core/database/database.dart';

/// Data access layer for the [workouts] and [workout_exercises] tables.
class WorkoutRepository {
  const WorkoutRepository(this._db);

  final AppDatabase _db;

  /// Returns all workouts owned by [userId], without their exercise lists.
  List<Row> findAllByUser(String userId) => _db.db.select(
        'SELECT id, title, description, rest_seconds, created_at '
        'FROM workouts WHERE user_id = ? ORDER BY created_at ASC',
        [userId],
      );

  /// Returns a single workout row owned by [userId], or `null`.
  Row? findByIdAndUser(String id, String userId) {
    final rows = _db.db.select(
      'SELECT id, title, description, rest_seconds, created_at '
      'FROM workouts WHERE id = ? AND user_id = ?',
      [id, userId],
    );
    return rows.isEmpty ? null : rows.first;
  }

  /// Returns the ordered exercises for [workoutId].
  List<Row> findExercises(String workoutId) => _db.db.select(
        'SELECT exercise_id, repetitions, series, sort_order '
        'FROM workout_exercises WHERE workout_id = ? ORDER BY sort_order ASC',
        [workoutId],
      );

  /// Inserts a workout and its exercises atomically.
  void insert({
    required String id,
    required String userId,
    required String title,
    String? description,
    required int restSeconds,
    required List<Map<String, dynamic>> exercises,
  }) {
    _db.db.execute(
      'INSERT INTO workouts (id, user_id, title, description, rest_seconds) '
      'VALUES (?, ?, ?, ?, ?)',
      [id, userId, title, description, restSeconds],
    );

    for (var i = 0; i < exercises.length; i++) {
      final ex = exercises[i];
      _db.db.execute(
        'INSERT INTO workout_exercises '
        '(workout_id, exercise_id, repetitions, series, sort_order) '
        'VALUES (?, ?, ?, ?, ?)',
        [id, ex['exercise_id'], ex['repetitions'], ex['series'], i],
      );
    }
  }

  /// Deletes the workout and its exercises (cascade handles the join rows).
  void delete(String id) =>
      _db.db.execute('DELETE FROM workouts WHERE id = ?', [id]);
}
