import 'package:shelf/shelf.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

import 'core/config/app_config.dart';
import 'core/database/database.dart';
import 'core/middleware/auth_middleware.dart';
import 'features/auth/auth_handler.dart';
import 'features/exercises/exercise_handler.dart';
import 'features/sessions/session_handler.dart';
import 'features/workouts/workout_handler.dart';

/// Builds the root [Handler] with all routes registered under `/api/v1/`.
///
/// API versioning is achieved via the URL prefix. A future `/api/v2/`
/// router can be mounted alongside v1 without breaking existing clients.
///
/// Auth middleware is applied at the *group* level (not per-route) so that
/// path-parameter handlers keep their correct `(Request, String)` signatures.
/// The two public auth endpoints are registered explicitly on the root router.
Handler buildRouter(AppConfig config, AppDatabase db) {
  final auth = AuthHandler(config, db);
  final exercises = ExerciseHandler(db);
  final workouts = WorkoutHandler(db);
  final sessions = SessionHandler(db);

  // ── Protected routes (/api/v1/* except register & login) ─────────────────
  // shelf_router accepts (Request, String) handlers for path parameters via
  // dynamic dispatch, so the auth middleware can safely be applied here at
  // the group level rather than individually on each route.
  final protectedRouter = Router()
    ..post('/auth/logout', auth.logout)
    ..get('/exercises', exercises.list)
    ..post('/exercises', exercises.create)
    ..put('/exercises/<id>', exercises.update)
    ..delete('/exercises/<id>', exercises.delete)
    ..get('/workouts', workouts.list)
    ..post('/workouts', workouts.create)
    ..delete('/workouts/<id>', workouts.delete)
    ..get('/sessions', sessions.list)
    ..post('/sessions', sessions.create);

  final protectedHandler = Pipeline()
      .addMiddleware(authMiddleware(config))
      .addHandler(protectedRouter.call);

  // ── Root router ──────────────────────────────────────────────────────────
  // Public auth endpoints are declared explicitly so they bypass the auth
  // middleware that covers everything under /api/v1/.
  final root = Router()
    ..post('/api/v1/auth/register', auth.register)
    ..post('/api/v1/auth/login', auth.login)
    ..mount('/api/v1', protectedHandler);

  return Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(root.call);
}
