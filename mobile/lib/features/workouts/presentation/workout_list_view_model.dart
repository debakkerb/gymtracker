import 'package:flutter/foundation.dart';

import '../../../core/api/api_exception.dart';
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
  ///
  /// Returns `null` on success, or a human-readable error message on failure.
  Future<String?> delete(String id) async {
    try {
      await _repository.remove(id);
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }
}
