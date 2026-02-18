import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/active_session/presentation/active_session_screen.dart';
import '../features/active_session/presentation/active_session_view_model.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/login_view_model.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/register_view_model.dart';
import '../features/exercises/data/exercise_repository.dart';
import '../features/exercises/presentation/exercise_create_screen.dart';
import '../features/exercises/presentation/exercise_create_view_model.dart';
import '../features/exercises/presentation/exercise_edit_screen.dart';
import '../features/exercises/presentation/exercise_edit_view_model.dart';
import '../features/exercises/presentation/exercise_list_screen.dart';
import '../features/exercises/presentation/exercise_list_view_model.dart';
import '../features/session_history/data/session_history_repository.dart';
import '../features/session_history/presentation/session_history_screen.dart';
import '../features/session_history/presentation/session_history_view_model.dart';
import '../features/workouts/data/workout_repository.dart';
import '../features/workouts/presentation/workout_create_screen.dart';
import '../features/workouts/presentation/workout_create_view_model.dart';
import '../features/workouts/presentation/workout_list_screen.dart';
import '../features/workouts/presentation/workout_list_view_model.dart';

/// Builds the application's [GoRouter] configuration.
GoRouter buildRouter({
  required AuthRepository authRepository,
  required ExerciseRepository exerciseRepository,
  required WorkoutRepository workoutRepository,
  required SessionHistoryRepository sessionHistoryRepository,
}) {
  return GoRouter(
    refreshListenable: authRepository.currentUser,
    redirect: (context, state) {
      final loggedIn = authRepository.currentUser.value != null;
      final path = state.uri.path;
      final isAuthRoute =
          path == '/login' || path == '/register';

      if (!loggedIn && !isAuthRoute) return '/login';
      if (loggedIn && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => WorkoutListScreen(
          viewModel: WorkoutListViewModel(
            repository: workoutRepository,
          ),
          exerciseRepository: exerciseRepository,
          authRepository: authRepository,
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(
          viewModel: LoginViewModel(
            repository: authRepository,
          ),
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterScreen(
          viewModel: RegisterViewModel(
            repository: authRepository,
          ),
        ),
      ),
      GoRoute(
        path: '/workouts/create',
        builder: (context, state) => WorkoutCreateScreen(
          viewModel: WorkoutCreateViewModel(
            repository: workoutRepository,
          ),
          exerciseRepository: exerciseRepository,
        ),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => SessionHistoryScreen(
          viewModel: SessionHistoryViewModel(
            repository: sessionHistoryRepository,
          ),
        ),
      ),
      GoRoute(
        path: '/sessions/active/:workoutId',
        builder: (context, state) {
          final id = state.pathParameters['workoutId']!;
          final workout = workoutRepository.findById(id);
          if (workout == null) {
            return const Scaffold(
              body: Center(
                child: Text('Workout not found'),
              ),
            );
          }
          return ActiveSessionScreen(
            viewModel: ActiveSessionViewModel(
              workout: workout,
              exerciseRepository: exerciseRepository,
              historyRepository: sessionHistoryRepository,
            ),
          );
        },
      ),
      GoRoute(
        path: '/exercises',
        builder: (context, state) => ExerciseListScreen(
          viewModel: ExerciseListViewModel(
            repository: exerciseRepository,
          ),
        ),
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) => ExerciseCreateScreen(
              viewModel: ExerciseCreateViewModel(
                repository: exerciseRepository,
              ),
            ),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              final exercise =
                  exerciseRepository.findById(id);
              if (exercise == null) {
                return const Scaffold(
                  body: Center(
                    child: Text('Exercise not found'),
                  ),
                );
              }
              return ExerciseEditScreen(
                viewModel: ExerciseEditViewModel(
                  repository: exerciseRepository,
                  exercise: exercise,
                ),
              );
            },
          ),
        ],
      ),
    ],
  );
}
