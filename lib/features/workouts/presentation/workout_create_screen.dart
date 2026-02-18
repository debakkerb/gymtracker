import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../exercises/data/exercise_repository.dart';
import '../domain/workout_exercise.dart';
import 'workout_create_view_model.dart';
import 'widgets/exercise_picker_sheet.dart';

/// Form screen for creating a new workout.
class WorkoutCreateScreen extends StatefulWidget {
  const WorkoutCreateScreen({
    required this.viewModel,
    required this.exerciseRepository,
    super.key,
  });

  final WorkoutCreateViewModel viewModel;
  final ExerciseRepository exerciseRepository;

  @override
  State<WorkoutCreateScreen> createState() =>
      _WorkoutCreateScreenState();
}

class _WorkoutCreateScreenState extends State<WorkoutCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  WorkoutCreateViewModel get _vm => widget.viewModel;

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    if (_vm.save()) {
      context.go('/');
    }
  }

  Future<void> _addExercise() async {
    final entry = await showExercisePickerSheet(
      context: context,
      exerciseRepository: widget.exerciseRepository,
    );
    if (entry != null) {
      _vm.addExercise(entry);
    }
  }

  String _exerciseName(WorkoutExercise entry) {
    final exercise =
        widget.exerciseRepository.findById(entry.exerciseId);
    return exercise?.title ?? 'Unknown exercise';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('New Workout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListenableBuilder(
            listenable: _vm,
            builder: (context, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g. Upper Body Day',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (value) => _vm.title = value,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Optional notes about this workout',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  onChanged: (value) => _vm.description = value,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Exercises',
                      style: textTheme.titleMedium,
                    ),
                    FilledButton.tonalIcon(
                      onPressed: _addExercise,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_vm.exercises.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'No exercises added yet',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  ..._buildExerciseList(colorScheme, textTheme),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _vm.canSubmit ? _onSave : null,
                    icon: const Icon(Icons.check),
                    label: const Text('Save Workout'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExerciseList(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return [
      for (var i = 0; i < _vm.exercises.length; i++)
        Card(
          child: ListTile(
            leading: Icon(
              Icons.fitness_center,
              color: colorScheme.primary,
            ),
            title: Text(_exerciseName(_vm.exercises[i])),
            subtitle: Text(
              '${_vm.exercises[i].repetitions} reps '
              '\u00d7 ${_vm.exercises[i].series} sets',
              style: textTheme.bodySmall,
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.remove_circle_outline,
                color: colorScheme.error,
              ),
              onPressed: () => _vm.removeExerciseAt(i),
            ),
          ),
        ),
    ];
  }
}
