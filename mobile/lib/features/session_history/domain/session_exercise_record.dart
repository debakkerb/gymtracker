/// Snapshot of one exercise as performed during a session.
class SessionExerciseRecord {
  const SessionExerciseRecord({
    required this.exerciseName,
    required this.repetitions,
    required this.series,
  });

  /// The exercise title, resolved at save time.
  final String exerciseName;

  /// Number of repetitions per set.
  final int repetitions;

  /// Number of sets performed.
  final int series;
}
