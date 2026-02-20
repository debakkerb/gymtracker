import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../domain/exercise.dart';

/// Remote-backed store for exercises.
///
/// All mutating operations call the API first, then update the local
/// [ValueNotifier] so the UI reacts without an extra round-trip.
class ExerciseRepository {
  ExerciseRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;
  final _exercises = ValueNotifier<List<Exercise>>([]);

  /// A listenable snapshot of all exercises.
  ValueListenable<List<Exercise>> get exercises => _exercises;

  /// Fetches the current user's exercises from the server.
  Future<void> load() async {
    final data = await _api.get('/exercises') as List<dynamic>;
    _exercises.value = data
        .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Clears the local list without a network call (used on logout).
  void clear() => _exercises.value = [];

  /// Creates an exercise on the server and returns the saved record.
  ///
  /// The server-assigned [Exercise.id] is used — any id on [exercise] is ignored.
  Future<Exercise> add(Exercise exercise) async {
    final data =
        await _api.post('/exercises', body: exercise.toJson())
            as Map<String, dynamic>;
    final saved = Exercise.fromJson(data);
    _exercises.value = [..._exercises.value, saved];
    return saved;
  }

  /// Deletes the exercise with [id] on the server and removes it locally.
  Future<void> remove(String id) async {
    await _api.delete('/exercises/$id');
    _exercises.value = _exercises.value.where((e) => e.id != id).toList();
  }

  /// Updates an exercise on the server and replaces it in the local list.
  Future<Exercise> update(Exercise updated) async {
    final data =
        await _api.put('/exercises/${updated.id}', body: updated.toJson())
            as Map<String, dynamic>;
    final saved = Exercise.fromJson(data);
    _exercises.value = [
      for (final e in _exercises.value)
        if (e.id == saved.id) saved else e,
    ];
    return saved;
  }

  /// Returns the exercise with [id] from the local list, or `null` if not found.
  Exercise? findById(String id) {
    for (final exercise in _exercises.value) {
      if (exercise.id == id) return exercise;
    }
    return null;
  }
}
