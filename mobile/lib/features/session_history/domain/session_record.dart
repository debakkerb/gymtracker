import 'session_exercise_record.dart';

/// A completed workout session.
class SessionRecord {
  const SessionRecord({
    required this.id,
    required this.workoutTitle,
    required this.date,
    required this.exercises,
  });

  /// Unique identifier (uuid).
  final String id;

  /// Snapshot of the workout title at the time of the session.
  final String workoutTitle;

  /// When the session was started.
  final DateTime date;

  /// Exercises performed, in order.
  final List<SessionExerciseRecord> exercises;
}
