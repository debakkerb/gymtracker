import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/database.dart';
import '../../core/http/json_response.dart' as r;
import '../../core/middleware/auth_middleware.dart';
import 'session_repository.dart';

/// Handles all `/api/v1/sessions` routes.
///
/// All routes require a valid JWT — enforced by [authMiddleware] in the router.
///
/// Session records are denormalised snapshots: exercise names and workout
/// titles are copied at save time so that history remains stable even if
/// the originals are later renamed or deleted.
///
/// Routes:
/// - `GET  /` — list sessions newest-first
/// - `POST /` — record a completed session
class SessionHandler {
  SessionHandler(AppDatabase db) : _repo = SessionRepository(db);

  final SessionRepository _repo;
  static const _uuid = Uuid();

  /// `GET /api/v1/sessions`
  Response list(Request request) {
    final sessions = _repo.findAllByUser(request.userId).map((row) {
      final exercises = _repo
          .findExercises(row['id'] as String)
          .map(_exerciseRowToMap)
          .toList();
      return {..._sessionRowToMap(row), 'exercises': exercises};
    }).toList();

    return r.ok(sessions);
  }

  /// `POST /api/v1/sessions`
  Future<Response> create(Request request) async {
    final body = await _parseJson(request);
    if (body == null) return r.badRequest('Request body must be valid JSON');

    final workoutTitle = (body['workout_title'] as String?)?.trim();
    final date = body['date'] as String?;
    final durationSeconds = (body['duration_seconds'] as num?)?.toInt() ?? 0;

    if (workoutTitle == null || workoutTitle.isEmpty) {
      return r.unprocessable('workout_title is required');
    }
    if (date == null || date.isEmpty) {
      return r.unprocessable('date is required (ISO 8601)');
    }

    final rawExercises = body['exercises'] as List<dynamic>?;
    if (rawExercises == null || rawExercises.isEmpty) {
      return r.unprocessable('exercises must contain at least one item');
    }

    final exercises = <Map<String, dynamic>>[];
    for (final item in rawExercises) {
      final ex = item as Map<String, dynamic>;
      final name = ex['exercise_name'] as String?;
      final reps = ex['repetitions'] as int?;
      final series = ex['series'] as int?;

      if (name == null || reps == null || series == null) {
        return r.unprocessable(
          'Each exercise must have exercise_name, repetitions, and series',
        );
      }
      exercises
          .add({'exercise_name': name, 'repetitions': reps, 'series': series});
    }

    final id = _uuid.v4();
    _repo.insert(
      id: id,
      userId: request.userId,
      workoutTitle: workoutTitle,
      date: date,
      durationSeconds: durationSeconds,
      exercises: exercises,
    );

    final sessionExercises =
        _repo.findExercises(id).map(_exerciseRowToMap).toList();
    return r.created({
      'id': id,
      'workout_title': workoutTitle,
      'date': date,
      'duration_seconds': durationSeconds,
      'exercises': sessionExercises,
    });
  }

  static Map<String, dynamic> _sessionRowToMap(dynamic row) => {
        'id': row['id'],
        'workout_title': row['workout_title'],
        'date': row['date'],
        'duration_seconds': row['duration_seconds'],
        'created_at': row['created_at'],
      };

  static Map<String, dynamic> _exerciseRowToMap(dynamic row) => {
        'exercise_name': row['exercise_name'],
        'repetitions': row['repetitions'],
        'series': row['series'],
      };

  static Future<Map<String, dynamic>?> _parseJson(Request request) async {
    try {
      return jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
