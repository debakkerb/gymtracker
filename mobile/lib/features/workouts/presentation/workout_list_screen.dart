import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/fitness_hero_banner.dart';
import '../../auth/data/auth_repository.dart';
import '../../exercises/data/exercise_repository.dart';
import '../domain/workout.dart';
import 'workout_list_view_model.dart';
import 'widgets/workout_card.dart';

/// Displays all workouts with an empty state and FAB to create.
class WorkoutListScreen extends StatelessWidget {
  const WorkoutListScreen({
    required this.viewModel,
    required this.exerciseRepository,
    required this.authRepository,
    super.key,
  });

  final WorkoutListViewModel viewModel;
  final ExerciseRepository exerciseRepository;
  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GymTracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authRepository.logout(),
            tooltip: 'Log out',
          ),
        ],
      ),
      body: Column(
        children: [
          const FitnessHeroBanner(
            title: 'Your Workouts',
            subtitle: 'Stay consistent, stay strong',
            height: 140,
          ),
          Expanded(
            child: ValueListenableBuilder<List<Workout>>(
              valueListenable: viewModel.workouts,
              builder: (context, workouts, _) {
                if (workouts.isEmpty) {
                  return const _EmptyState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 88),
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    final workout = workouts[index];
                    return WorkoutCard(
                      workout: workout,
                      exerciseRepository: exerciseRepository,
                      onDelete: () => _confirmDelete(context, workout),
                      onStartSession: () =>
                          context.go('/sessions/active/${workout.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _BottomActions(),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Workout workout) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete workout?'),
        content: Text('Are you sure you want to delete "${workout.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final error = await viewModel.delete(workout.id);
      if (error != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No workouts yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Use the buttons below to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => context.go('/exercises'),
                icon: const Icon(Icons.fitness_center),
                label: const Text('Exercises'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: colorScheme.secondaryContainer,
                  foregroundColor: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => context.go('/history'),
                icon: const Icon(Icons.history),
                label: const Text('History'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: colorScheme.tertiaryContainer,
                  foregroundColor: colorScheme.onTertiaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => context.go('/workouts/create'),
                icon: const Icon(Icons.add),
                label: const Text('Workout'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
