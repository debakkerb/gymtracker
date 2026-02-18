import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'active_session_view_model.dart';
import 'widgets/rest_timer_widget.dart';

/// Rest duration must match the constant in the view model.
const _restDuration = 120;

/// A guided session screen that walks through each exercise
/// set-by-set with a rest timer between sets.
class ActiveSessionScreen extends StatefulWidget {
  const ActiveSessionScreen({required this.viewModel, super.key});

  final ActiveSessionViewModel viewModel;

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen> {
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  Future<bool> _confirmExit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End session?'),
        content: const Text('Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('End'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    final localizations = MaterialLocalizations.of(context);
    final formattedDate = localizations.formatMediumDate(vm.date);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final router = GoRouter.of(context);
        if (vm.state.isComplete) {
          router.go('/');
          return;
        }
        final shouldExit = await _confirmExit();
        if (shouldExit && mounted) {
          router.go('/');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Session \u2014 $formattedDate'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final router = GoRouter.of(context);
              if (vm.state.isComplete) {
                router.go('/');
                return;
              }
              final shouldExit = await _confirmExit();
              if (shouldExit && mounted) {
                router.go('/');
              }
            },
          ),
        ),
        body: ListenableBuilder(
          listenable: vm,
          builder: (context, _) {
            final state = vm.state;

            if (state.isComplete) {
              return _CompletionView(onDone: () => context.go('/'));
            }

            final exercise = vm.currentExercise;
            final name = vm.exerciseName(exercise.exerciseId);
            final totalExercises = vm.workout.exercises.length;

            if (state.isResting) {
              return _RestView(
                exerciseName: name,
                remainingSeconds: state.remainingSeconds,
                onSkip: vm.skipRest,
              );
            }

            return _ExerciseView(
              exerciseName: name,
              currentSet: state.currentSet,
              totalSets: exercise.series,
              exerciseNumber: state.exerciseIndex + 1,
              totalExercises: totalExercises,
              repetitions: exercise.repetitions,
              onComplete: vm.completeSet,
            );
          },
        ),
      ),
    );
  }
}

class _CompletionView extends StatelessWidget {
  const _CompletionView({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 96,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Workout complete!',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onDone,
              icon: const Icon(Icons.home),
              label: const Text('Back to workouts'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestView extends StatelessWidget {
  const _RestView({
    required this.exerciseName,
    required this.remainingSeconds,
    required this.onSkip,
  });

  final String exerciseName;
  final int remainingSeconds;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              exerciseName,
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Rest',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            RestTimerWidget(
              remainingSeconds: remainingSeconds,
              totalSeconds: _restDuration,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: onSkip,
              icon: const Icon(Icons.skip_next),
              label: const Text('Skip rest'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseView extends StatelessWidget {
  const _ExerciseView({
    required this.exerciseName,
    required this.currentSet,
    required this.totalSets,
    required this.exerciseNumber,
    required this.totalExercises,
    required this.repetitions,
    required this.onComplete,
  });

  final String exerciseName;
  final int currentSet;
  final int totalSets;
  final int exerciseNumber;
  final int totalExercises;
  final int repetitions;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              exerciseName,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Set $currentSet of $totalSets',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Exercise $exerciseNumber of '
              '$totalExercises',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '$repetitions reps',
              style: textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 40),
            FilledButton.icon(
              onPressed: onComplete,
              icon: const Icon(Icons.check),
              label: const Text('Complete Set'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
