import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

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
  final List<WorkoutExercise> _exercises = [];

  /// The current list of exercises in this workout.
  List<WorkoutExercise> get exercises => List.unmodifiable(_exercises);

  /// Whether the form has enough data to submit.
  ///
  /// Requires a non-empty title and at least one exercise.
  bool get canSubmit => _title.trim().isNotEmpty && _exercises.isNotEmpty;

  set title(String value) {
    _title = value;
    notifyListeners();
  }

  set description(String value) {
    _description = value;
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

  /// Saves the workout and returns `true` on success.
  bool save() {
    if (!canSubmit) return false;

    final workout = Workout(
      id: _uuid.v4(),
      title: _title.trim(),
      description: _description.trim().isEmpty ? null : _description.trim(),
      exercises: List.unmodifiable(_exercises),
    );
    _repository.add(workout);
    return true;
  }
}
