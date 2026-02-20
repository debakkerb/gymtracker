import 'session_exercise_record.dart';

/// A completed workout session.
class SessionRecord {
  const SessionRecord({
    required this.id,
    required this.workoutTitle,
    required this.date,
    required this.duration,
    required this.exercises,
  });

  /// Unique identifier (uuid).
  final String id;

  /// Snapshot of the workout title at the time of the session.
  final String workoutTitle;

  /// When the session was started.
  final DateTime date;

  /// Total time taken to complete the session.
  final Duration duration;

  /// Exercises performed, in order.
  final List<SessionExerciseRecord> exercises;

  factory SessionRecord.fromJson(Map<String, dynamic> json) => SessionRecord(
    id: json['id'] as String,
    workoutTitle: json['workout_title'] as String,
    date: DateTime.parse(json['date'] as String),
    duration: Duration(seconds: (json['duration_seconds'] as int?) ?? 0),
    exercises: (json['exercises'] as List<dynamic>)
        .map((e) => SessionExerciseRecord.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  /// Serialises for API create requests.
  ///
  /// The [id] field is intentionally omitted — it is assigned by the server.
  Map<String, dynamic> toJson() => {
    'workout_title': workoutTitle,
    'date': date.toIso8601String(),
    'duration_seconds': duration.inSeconds,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };
}
