import 'package:flutter/foundation.dart';

import '../domain/exercise.dart';

/// In-memory storage for exercises.
///
/// Exposes a [ValueNotifier] so the UI can rebuild reactively
/// whenever the list changes.
class ExerciseRepository {
  final _exercises = ValueNotifier<List<Exercise>>([]);

  /// A listenable snapshot of all exercises.
  ValueListenable<List<Exercise>> get exercises => _exercises;

  /// Adds [exercise] to the store and notifies listeners.
  void add(Exercise exercise) {
    _exercises.value = [..._exercises.value, exercise];
  }

  /// Removes the exercise with [id] and notifies listeners.
  void remove(String id) {
    _exercises.value =
        _exercises.value.where((e) => e.id != id).toList();
  }

  /// Replaces the exercise with the same [Exercise.id].
  void update(Exercise updated) {
    _exercises.value = [
      for (final e in _exercises.value)
        if (e.id == updated.id) updated else e,
    ];
  }

  /// Returns the exercise with [id], or `null` if not found.
  Exercise? findById(String id) {
    final list = _exercises.value;
    for (final exercise in list) {
      if (exercise.id == id) return exercise;
    }
    return null;
  }
}
