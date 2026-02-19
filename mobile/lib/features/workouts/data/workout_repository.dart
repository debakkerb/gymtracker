import 'package:flutter/foundation.dart';

import '../domain/workout.dart';

/// In-memory storage for workouts.
///
/// Exposes a [ValueNotifier] so the UI can rebuild reactively
/// whenever the list changes.
class WorkoutRepository {
  final _workouts = ValueNotifier<List<Workout>>([]);

  /// A listenable snapshot of all workouts.
  ValueListenable<List<Workout>> get workouts => _workouts;

  /// Adds [workout] to the store and notifies listeners.
  void add(Workout workout) {
    _workouts.value = [..._workouts.value, workout];
  }

  /// Removes the workout with [id] and notifies listeners.
  void remove(String id) {
    _workouts.value = _workouts.value.where((w) => w.id != id).toList();
  }

  /// Returns the workout with [id], or `null` if not found.
  Workout? findById(String id) {
    final list = _workouts.value;
    for (final workout in list) {
      if (workout.id == id) return workout;
    }
    return null;
  }
}
