/// Immutable snapshot of an active workout session.
class ActiveSessionState {
  const ActiveSessionState({
    this.exerciseIndex = 0,
    this.currentSet = 1,
    this.isResting = false,
    this.remainingSeconds = 0,
    this.isComplete = false,
  });

  /// Zero-based index of the current exercise.
  final int exerciseIndex;

  /// One-based set number within the current exercise.
  final int currentSet;

  /// Whether the rest countdown timer is active.
  final bool isResting;

  /// Seconds left on the rest timer (120 → 0).
  final int remainingSeconds;

  /// Whether all exercises and sets have been completed.
  final bool isComplete;
}
