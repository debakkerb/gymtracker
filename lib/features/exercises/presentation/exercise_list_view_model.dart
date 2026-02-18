import 'package:flutter/foundation.dart';

import '../data/exercise_repository.dart';
import '../domain/exercise.dart';

/// Exposes the exercise list and delete action to the UI.
class ExerciseListViewModel {
  ExerciseListViewModel({required ExerciseRepository repository})
      : _repository = repository;

  final ExerciseRepository _repository;

  /// Reactive list of all exercises.
  ValueListenable<List<Exercise>> get exercises =>
      _repository.exercises;

  /// Deletes the exercise with [id].
  void delete(String id) => _repository.remove(id);
}
