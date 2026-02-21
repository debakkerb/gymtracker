import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/database.dart';
import '../../core/http/json_response.dart' as r;
import '../../core/middleware/auth_middleware.dart';
import 'workout_repository.dart';

/// Handles all `/api/v1/workouts` routes.
///
/// All routes require a valid JWT — enforced by [authMiddleware] in the router.
///
/// Routes:
/// - `GET    /`    — list workouts with their exercise lists
/// - `POST   /`    — create a workout and its exercises atomically
/// - `DELETE /:id` — delete a workout (cascades to its exercises)
///
/// There is no `PUT` yet because the app has no workout-edit screen.
class WorkoutHandler {
  WorkoutHandler(AppDatabase db) : _repo = WorkoutRepository(db);

  final WorkoutRepository _repo;
  static const _uuid = Uuid();

  /// `GET /api/v1/workouts`
  Response list(Request request) {
    final workouts = _repo.findAllByUser(request.userId).map((row) {
      final exercises = _repo
          .findExercises(row['id'] as String)
          .map(_exerciseRowToMap)
          .toList();
      return {..._workoutRowToMap(row), 'exercises': exercises};
    }).toList();

    return r.ok(workouts);
  }

  /// `POST /api/v1/workouts`
  Future<Response> create(Request request) async {
    final body = await _parseJson(request);
    if (body == null) return r.badRequest('Request body must be valid JSON');

    final title = (body['title'] as String?)?.trim();
    if (title == null || title.isEmpty) {
      return r.unprocessable('title is required');
    }

    final rawExercises = body['exercises'] as List<dynamic>?;
    if (rawExercises == null || rawExercises.isEmpty) {
      return r.unprocessable('exercises must contain at least one item');
    }

    final exercises = <Map<String, dynamic>>[];
    for (final item in rawExercises) {
      final ex = item as Map<String, dynamic>;
      final exerciseId = ex['exercise_id'] as String?;
      final reps = ex['repetitions'] as int?;
      final series = ex['series'] as int?;

      if (exerciseId == null || reps == null || series == null) {
        return r.unprocessable(
          'Each exercise must have exercise_id, repetitions, and series',
        );
      }
      exercises.add(
        {'exercise_id': exerciseId, 'repetitions': reps, 'series': series},
      );
    }

    final restSeconds =
        (body['rest_seconds'] as num?)?.toInt() ?? 120;

    final id = _uuid.v4();
    _repo.insert(
      id: id,
      userId: request.userId,
      title: title,
      description: body['description'] as String?,
      restSeconds: restSeconds,
      exercises: exercises,
    );

    final created = _repo.findByIdAndUser(id, request.userId)!;
    final createdExercises =
        _repo.findExercises(id).map(_exerciseRowToMap).toList();
    return r
        .created({..._workoutRowToMap(created), 'exercises': createdExercises});
  }

  /// `DELETE /api/v1/workouts/:id`
  Response delete(Request request, String id) {
    final existing = _repo.findByIdAndUser(id, request.userId);
    if (existing == null) return r.notFound('Workout not found');

    _repo.delete(id);
    return r.ok({'message': 'Workout deleted'});
  }

  static Map<String, dynamic> _workoutRowToMap(dynamic row) => {
        'id': row['id'],
        'title': row['title'],
        'description': row['description'],
        'rest_seconds': row['rest_seconds'],
        'created_at': row['created_at'],
      };

  static Map<String, dynamic> _exerciseRowToMap(dynamic row) => {
        'exercise_id': row['exercise_id'],
        'repetitions': row['repetitions'],
        'series': row['series'],
        'sort_order': row['sort_order'],
      };

  static Future<Map<String, dynamic>?> _parseJson(Request request) async {
    try {
      return jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
