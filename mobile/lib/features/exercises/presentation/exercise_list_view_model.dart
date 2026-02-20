import 'package:flutter/foundation.dart';

import '../../../core/api/api_exception.dart';
import '../data/exercise_repository.dart';
import '../domain/exercise.dart';

/// Exposes the exercise list and delete action to the UI.
class ExerciseListViewModel {
  ExerciseListViewModel({required ExerciseRepository repository})
    : _repository = repository;

  final ExerciseRepository _repository;

  /// Reactive list of all exercises.
  ValueListenable<List<Exercise>> get exercises => _repository.exercises;

  /// Deletes the exercise with [id].
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
