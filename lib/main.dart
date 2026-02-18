import 'package:flutter/material.dart';

import 'app.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/exercises/data/exercise_repository.dart';
import 'features/session_history/data/session_history_repository.dart';
import 'features/workouts/data/workout_repository.dart';
import 'routing/app_router.dart';

void main() {
  final authRepository = AuthRepository();
  final exerciseRepository = ExerciseRepository();
  final workoutRepository = WorkoutRepository();
  final sessionHistoryRepository =
      SessionHistoryRepository();
  final router = buildRouter(
    authRepository: authRepository,
    exerciseRepository: exerciseRepository,
    workoutRepository: workoutRepository,
    sessionHistoryRepository: sessionHistoryRepository,
  );

  runApp(App(router: router));
}
