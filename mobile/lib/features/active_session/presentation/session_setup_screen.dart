import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../exercises/data/exercise_repository.dart';
import '../../workouts/domain/workout.dart';
import '../../workouts/domain/workout_exercise.dart';

/// Pre-session screen that lists all exercises and allows the user to
/// reorder them before starting.
///
/// Reordering is session-only — the stored [Workout] is never modified.
class SessionSetupScreen extends StatefulWidget {
  const SessionSetupScreen({
    required this.workout,
    required this.exerciseRepository,
    super.key,
  });

  final Workout workout;
  final ExerciseRepository exerciseRepository;

  @override
  State<SessionSetupScreen> createState() => _SessionSetupScreenState();
}

class _SessionSetupScreenState extends State<SessionSetupScreen> {
  /// Each entry pairs a stable [UniqueKey] with a [WorkoutExercise] so the
  /// drag handle works correctly even when the same exercise appears more than
  /// once in a workout.
  late final List<(UniqueKey, WorkoutExercise)> _entries;

  @override
  void initState() {
    super.initState();
    _entries = widget.workout.exercises.map((e) => (UniqueKey(), e)).toList();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _entries.removeAt(oldIndex);
      _entries.insert(newIndex, item);
    });
  }

  void _startSession() {
    final reordered = widget.workout.withExercises(
      _entries.map((t) => t.$2).toList(),
    );
    context.go('/sessions/active/${widget.workout.id}', extra: reordered);
  }

  String _exerciseName(WorkoutExercise entry) =>
      widget.exerciseRepository.findById(entry.exerciseId)?.title ??
      'Unknown exercise';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.workout.title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Drag to reorder — changes apply to this session only.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: _entries.length,
              onReorder: _onReorder,
              itemBuilder: (context, index) {
                final (key, entry) = _entries[index];
                return _ExerciseRow(
                  key: key,
                  index: index,
                  name: _exerciseName(entry),
                  repetitions: entry.repetitions,
                  series: entry.series,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton.icon(
            onPressed: _startSession,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Session'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required super.key,
    required this.index,
    required this.name,
    required this.repetitions,
    required this.series,
    required this.colorScheme,
    required this.textTheme,
  });

  final int index;
  final String name;
  final int repetitions;
  final int series;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        child: Text(
          '${index + 1}',
          style: TextStyle(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(name),
      subtitle: Text(
        '$repetitions reps \u00d7 $series sets',
        style: textTheme.bodySmall,
      ),
      trailing: Icon(Icons.drag_handle, color: colorScheme.onSurfaceVariant),
    );
  }
}
