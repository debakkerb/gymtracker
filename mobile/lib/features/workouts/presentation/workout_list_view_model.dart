import 'package:flutter/foundation.dart';

import '../data/workout_repository.dart';
import '../domain/workout.dart';

/// Exposes the workout list and delete action to the UI.
class WorkoutListViewModel {
  WorkoutListViewModel({required WorkoutRepository repository})
    : _repository = repository;

  final WorkoutRepository _repository;

  /// Reactive list of all workouts.
  ValueListenable<List<Workout>> get workouts => _repository.workouts;

  /// Deletes the workout with [id].
  void delete(String id) => _repository.remove(id);
}
