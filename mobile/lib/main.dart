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

  final exerciseRepository = ExerciseRepository(apiClient: apiClient);
  final workoutRepository = WorkoutRepository(apiClient: apiClient);
  final sessionHistoryRepository = SessionHistoryRepository(
    apiClient: apiClient,
  );

  // Load or clear data whenever the auth state changes (login, logout,
  // session restore). Using a listener means this runs for all auth events
  // without coupling AuthRepository to the other repositories.
  authRepository.currentUser.addListener(() {
    if (authRepository.currentUser.value != null) {
      exerciseRepository.load().catchError((_) {});
      workoutRepository.load().catchError((_) {});
      sessionHistoryRepository.load().catchError((_) {});
    } else {
      exerciseRepository.clear();
      workoutRepository.clear();
      sessionHistoryRepository.clear();
    }
  });

  // Pre-load immediately if a session was already restored above.
  if (authRepository.currentUser.value != null) {
    await Future.wait([
      exerciseRepository.load().catchError((_) {}),
      workoutRepository.load().catchError((_) {}),
      sessionHistoryRepository.load().catchError((_) {}),
    ]);
  }

  final router = buildRouter(
    authRepository: authRepository,
    exerciseRepository: exerciseRepository,
    workoutRepository: workoutRepository,
    sessionHistoryRepository: sessionHistoryRepository,
  );

  runApp(App(router: router));
}
