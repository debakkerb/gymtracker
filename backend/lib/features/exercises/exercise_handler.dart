import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/database.dart';
import '../../core/http/json_response.dart' as r;
import '../../core/middleware/auth_middleware.dart';
import 'exercise_repository.dart';

/// Handles all `/api/v1/exercises` routes.
///
/// All routes require a valid JWT — enforced by [authMiddleware] in the router.
///
/// Routes:
/// - `GET    /`    — list exercises for the authenticated user
/// - `POST   /`    — create a new exercise
/// - `PUT    /:id` — replace an existing exercise
/// - `DELETE /:id` — delete an exercise
///
/// Image upload is not yet implemented. The `image_url` field is accepted
/// as a plain string for now; a multipart upload endpoint can be added
/// at `POST /exercises/:id/image` in a future iteration.
class ExerciseHandler {
  ExerciseHandler(AppDatabase db) : _repo = ExerciseRepository(db);

  final ExerciseRepository _repo;
  static const _uuid = Uuid();

  /// `GET /api/v1/exercises`
  Response list(Request request) {
    final exercises = _repo
        .findAllByUser(request.userId)
        .map(_rowToMap)
        .toList();
    return r.ok(exercises);
  }

  /// `POST /api/v1/exercises`
  Future<Response> create(Request request) async {
    final body = await _parseJson(request);
    if (body == null) return r.badRequest('Request body must be valid JSON');

    final title = (body['title'] as String?)?.trim();
    if (title == null || title.isEmpty) {
      return r.unprocessable('title is required');
    }

    final id = _uuid.v4();
    _repo.insert(
      id: id,
      userId: request.userId,
      title: title,
      description: body['description'] as String?,
      externalLink: body['external_link'] as String?,
      imageUrl: body['image_url'] as String?,
    );

    final created = _repo.findByIdAndUser(id, request.userId)!;
    return r.created(_rowToMap(created));
  }

  /// `PUT /api/v1/exercises/:id`
  Future<Response> update(Request request, String id) async {
    final existing = _repo.findByIdAndUser(id, request.userId);
    if (existing == null) return r.notFound('Exercise not found');

    final body = await _parseJson(request);
    if (body == null) return r.badRequest('Request body must be valid JSON');

    final title = (body['title'] as String?)?.trim();
    if (title == null || title.isEmpty) {
      return r.unprocessable('title is required');
    }

    _repo.update(
      id: id,
      title: title,
      description: body['description'] as String?,
      externalLink: body['external_link'] as String?,
      imageUrl: body['image_url'] as String?,
    );

    final updated = _repo.findByIdAndUser(id, request.userId)!;
    return r.ok(_rowToMap(updated));
  }

  /// `DELETE /api/v1/exercises/:id`
  Response delete(Request request, String id) {
    final existing = _repo.findByIdAndUser(id, request.userId);
    if (existing == null) return r.notFound('Exercise not found');

    _repo.delete(id);
    return r.ok({'message': 'Exercise deleted'});
  }

  static Map<String, dynamic> _rowToMap(dynamic row) => {
        'id': row['id'],
        'title': row['title'],
        'description': row['description'],
        'external_link': row['external_link'],
        'image_url': row['image_url'],
        'created_at': row['created_at'],
      };

  static Future<Map<String, dynamic>?> _parseJson(Request request) async {
    try {
      return jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
