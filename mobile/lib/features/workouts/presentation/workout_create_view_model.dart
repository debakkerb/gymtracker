import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_exception.dart';
import '../data/workout_repository.dart';
import '../domain/workout.dart';
import '../domain/workout_exercise.dart';

/// Manages the form state for creating a new workout.
class WorkoutCreateViewModel extends ChangeNotifier {
  WorkoutCreateViewModel({required WorkoutRepository repository})
    : _repository = repository;

  final WorkoutRepository _repository;
  static const _uuid = Uuid();

  String _title = '';
  String _description = '';
  int _restSeconds = 120;
  final List<WorkoutExercise> _exercises = [];
  bool _isLoading = false;

  /// The current list of exercises in this workout.
  List<WorkoutExercise> get exercises => List.unmodifiable(_exercises);

  /// Rest duration between sets, in seconds.
  int get restSeconds => _restSeconds;

  /// Whether the form has enough data to submit.
  ///
  /// Requires a non-empty title and at least one exercise.
  bool get canSubmit =>
      _title.trim().isNotEmpty && _exercises.isNotEmpty && !_isLoading;

  set title(String value) {
    _title = value;
    notifyListeners();
  }

  set description(String value) {
    _description = value;
    notifyListeners();
  }

  set restSeconds(int value) {
    _restSeconds = value;
    notifyListeners();
  }

  /// Adds an exercise entry to the workout.
  void addExercise(WorkoutExercise exercise) {
    _exercises.add(exercise);
    notifyListeners();
  }

  /// Removes the exercise entry at [index].
  void removeExerciseAt(int index) {
    _exercises.removeAt(index);
    notifyListeners();
  }

  /// Saves the workout to the server.
  ///
  /// Returns `null` on success, or a human-readable error message on failure.
  Future<String?> save() async {
    if (!canSubmit) return null;
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.add(
        Workout(
          id: _uuid.v4(),
          title: _title.trim(),
          description: _description.trim().isEmpty ? null : _description.trim(),
          restSeconds: _restSeconds,
          exercises: List.unmodifiable(_exercises),
        ),
      );
      return null;
    } on ApiException catch (e) {
      return e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
