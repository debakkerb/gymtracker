import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../domain/workout.dart';

/// Remote-backed store for workouts.
///
/// All mutating operations call the API first, then update the local
/// [ValueNotifier] so the UI reacts without an extra round-trip.
class WorkoutRepository {
  WorkoutRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;
  final _workouts = ValueNotifier<List<Workout>>([]);

  /// A listenable snapshot of all workouts.
  ValueListenable<List<Workout>> get workouts => _workouts;

  /// Fetches the current user's workouts from the server.
  Future<void> load() async {
    final data = await _api.get('/workouts') as List<dynamic>;
    _workouts.value = data
        .map((e) => Workout.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Clears the local list without a network call (used on logout).
  void clear() => _workouts.value = [];

  /// Creates a workout on the server and returns the saved record.
  ///
  /// The server-assigned [Workout.id] is used — any id on [workout] is ignored.
  Future<Workout> add(Workout workout) async {
    final data =
        await _api.post('/workouts', body: workout.toJson())
            as Map<String, dynamic>;
    final saved = Workout.fromJson(data);
    _workouts.value = [..._workouts.value, saved];
    return saved;
  }

  /// Deletes the workout with [id] on the server and removes it locally.
  Future<void> remove(String id) async {
    await _api.delete('/workouts/$id');
    _workouts.value = _workouts.value.where((w) => w.id != id).toList();
  }

  /// Returns the workout with [id] from the local list, or `null` if not found.
  Workout? findById(String id) {
    for (final workout in _workouts.value) {
      if (workout.id == id) return workout;
    }
    return null;
  }
}
