import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../exercises/data/exercise_repository.dart';
import '../../session_history/data/session_history_repository.dart';
import '../../session_history/domain/session_exercise_record.dart';
import '../../session_history/domain/session_record.dart';
import '../../workouts/domain/workout.dart';
import '../../workouts/domain/workout_exercise.dart';
import '../domain/active_session_state.dart';

/// Drives an active workout session, managing set progression
/// and a countdown rest timer between sets.
class ActiveSessionViewModel extends ChangeNotifier {
  ActiveSessionViewModel({
    required this.workout,
    required ExerciseRepository exerciseRepository,
    required SessionHistoryRepository historyRepository,
  }) : _exerciseRepository = exerciseRepository,
       _historyRepository = historyRepository,
       date = DateTime.now() {
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      notifyListeners();
    });
  }

  final Workout workout;
  final ExerciseRepository _exerciseRepository;
  final SessionHistoryRepository _historyRepository;

  /// The date this session was started.
  final DateTime date;

  int _exerciseIndex = 0;
  int _currentSet = 1;
  bool _isResting = false;
  int _remainingSeconds = 0;
  bool _isComplete = false;
  int _elapsedSeconds = 0;
  Timer? _timer;
  Timer? _elapsedTimer;

  /// A snapshot of the current session state.
  ActiveSessionState get state => ActiveSessionState(
    exerciseIndex: _exerciseIndex,
    currentSet: _currentSet,
    isResting: _isResting,
    remainingSeconds: _remainingSeconds,
    isComplete: _isComplete,
    elapsedSeconds: _elapsedSeconds,
  );

  /// The exercise currently being performed.
  WorkoutExercise get currentExercise => workout.exercises[_exerciseIndex];

  /// The configured rest duration for this workout, in seconds.
  int get restDuration => workout.restSeconds;

  /// Marks the current set as done. If more work remains,
  /// starts a 2-minute rest timer; otherwise marks the
  /// session complete.
  void completeSet() {
    if (_isComplete) return;

    final isLastSet = _currentSet >= currentExercise.series;
    final isLastExercise = _exerciseIndex >= workout.exercises.length - 1;

    if (isLastSet && isLastExercise) {
      _elapsedTimer?.cancel();
      _elapsedTimer = null;
      _isComplete = true;
      _saveSession(); // fire-and-forget; optimistic local update is synchronous
      notifyListeners();
      return;
    }

    _startRestTimer();
  }

  /// Cancels the rest timer and advances immediately.
  void skipRest() {
    _cancelTimer();
    _isResting = false;
    _advance();
    notifyListeners();
  }

  /// Resolves an exercise ID to its display name.
  String exerciseName(String exerciseId) {
    final exercise = _exerciseRepository.findById(exerciseId);
    return exercise?.title ?? 'Unknown exercise';
  }

  Future<void> _saveSession() async {
    final exercises = workout.exercises.map(
      (e) => SessionExerciseRecord(
        exerciseName: exerciseName(e.exerciseId),
        repetitions: e.repetitions,
        series: e.series,
      ),
    );
    try {
      await _historyRepository.add(
        SessionRecord(
          id: const Uuid().v4(),
          workoutTitle: workout.title,
          date: date,
          duration: Duration(seconds: _elapsedSeconds),
          exercises: exercises.toList(),
        ),
      );
    } catch (_) {
      // Best-effort — the session is already shown locally.
    }
  }

  void _startRestTimer() {
    _isResting = true;
    _remainingSeconds = workout.restSeconds;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _remainingSeconds--;
      if (_remainingSeconds <= 0) {
        _cancelTimer();
        _isResting = false;
        _advance();
      }
      notifyListeners();
    });
  }

  /// Moves to the next set or next exercise.
  void _advance() {
    if (_currentSet < currentExercise.series) {
      _currentSet++;
    } else if (_exerciseIndex < workout.exercises.length - 1) {
      _exerciseIndex++;
      _currentSet = 1;
    } else {
      _isComplete = true;
    }
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    _elapsedTimer?.cancel();
    super.dispose();
  }
}
