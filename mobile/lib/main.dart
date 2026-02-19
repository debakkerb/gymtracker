import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app.dart';
import 'core/api/api_client.dart';
import 'core/auth/token_storage.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/exercises/data/exercise_repository.dart';
import 'features/session_history/data/session_history_repository.dart';
import 'features/workouts/data/workout_repository.dart';
import 'routing/app_router.dart';

/// Base URL for the GymTracker backend.
///
/// - Android emulator → 'http://10.0.2.2:8080'
/// - iOS simulator / web / desktop → 'http://localhost:8080'
const _backendUrl = 'http://localhost:8080';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = TokenStorage(const FlutterSecureStorage());
  final apiClient = ApiClient(baseUrl: _backendUrl, tokenStorage: tokenStorage);

  final authRepository = AuthRepository(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );
  // Restore any persisted session before the first frame is drawn.
  await authRepository.init();

  final exerciseRepository = ExerciseRepository();
  final workoutRepository = WorkoutRepository();
  final sessionHistoryRepository = SessionHistoryRepository();

  final router = buildRouter(
    authRepository: authRepository,
    exerciseRepository: exerciseRepository,
    workoutRepository: workoutRepository,
    sessionHistoryRepository: sessionHistoryRepository,
  );

  runApp(App(router: router));
}
