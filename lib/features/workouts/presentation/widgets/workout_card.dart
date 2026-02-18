import 'package:flutter/material.dart';

import '../../../exercises/data/exercise_repository.dart';
import '../../domain/workout.dart';
import '../../domain/workout_exercise.dart';

/// An expandable card that shows a workout's exercises.
class WorkoutCard extends StatelessWidget {
  const WorkoutCard({
    required this.workout,
    required this.exerciseRepository,
    required this.onDelete,
    required this.onStartSession,
    super.key,
  });

  final Workout workout;
  final ExerciseRepository exerciseRepository;
  final VoidCallback onDelete;
  final VoidCallback onStartSession;

  String _exerciseName(WorkoutExercise entry) {
    final exercise = exerciseRepository.findById(entry.exerciseId);
    return exercise?.title ?? 'Unknown exercise';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            workout.title.characters.first.toUpperCase(),
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(workout.title),
        subtitle: Text(
          '${workout.exercises.length} '
          'exercise${workout.exercises.length == 1 ? '' : 's'}',
          style: textTheme.bodySmall,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (workout.description != null) ...[
                  Text(
                    workout.description!,
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                ],
                ...workout.exercises.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _exerciseName(entry),
                            style: textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          '${entry.repetitions} reps '
                          '\u00d7 ${entry.series} sets',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline,
                        color: colorScheme.error,
                      ),
                      label: Text(
                        'Delete',
                        style: TextStyle(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: onStartSession,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
