import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../../exercises/data/exercise_repository.dart';
import '../../../exercises/domain/exercise.dart';
import '../../domain/workout_exercise.dart';

/// A modal bottom sheet that lets the user pick an exercise and
/// enter repetitions and series.
///
/// Returns a [WorkoutExercise] if confirmed, or `null` if dismissed.
Future<WorkoutExercise?> showExercisePickerSheet({
  required BuildContext context,
  required ExerciseRepository exerciseRepository,
}) {
  return showModalBottomSheet<WorkoutExercise>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _ExercisePickerSheet(
      exerciseRepository: exerciseRepository,
    ),
  );
}

class _ExercisePickerSheet extends StatefulWidget {
  const _ExercisePickerSheet({required this.exerciseRepository});

  final ExerciseRepository exerciseRepository;

  @override
  State<_ExercisePickerSheet> createState() =>
      _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<_ExercisePickerSheet> {
  static const _uuid = Uuid();

  Exercise? _selected;
  final _repsController = TextEditingController();
  final _seriesController = TextEditingController();

  bool get _canConfirm =>
      _selected != null &&
      (int.tryParse(_repsController.text) ?? 0) > 0 &&
      (int.tryParse(_seriesController.text) ?? 0) > 0;

  void _onConfirm() {
    if (!_canConfirm) return;
    Navigator.pop(
      context,
      WorkoutExercise(
        exerciseId: _selected!.id,
        repetitions: int.parse(_repsController.text),
        series: int.parse(_seriesController.text),
      ),
    );
  }

  Future<void> _createExercise() async {
    final title = await showDialog<String>(
      context: context,
      builder: (context) => const _QuickCreateDialog(),
    );
    if (title == null || title.trim().isEmpty) return;

    final exercise = Exercise(
      id: _uuid.v4(),
      title: title.trim(),
    );
    widget.exerciseRepository.add(exercise);
    setState(() => _selected = exercise);
  }

  @override
  void dispose() {
    _repsController.dispose();
    _seriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return ValueListenableBuilder<List<Exercise>>(
      valueListenable: widget.exerciseRepository.exercises,
      builder: (context, exercises, _) {
        return Padding(
          padding:
              EdgeInsets.fromLTRB(16, 24, 16, 16 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Exercise',
                    style:
                        Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton.icon(
                    onPressed: _createExercise,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Create new'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Exercise>(
                decoration: const InputDecoration(
                  labelText: 'Exercise',
                  border: OutlineInputBorder(),
                ),
                initialValue: _selected,
                items: exercises
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.title),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selected = value),
              ),
              if (exercises.isEmpty)
                Padding(
                  padding:
                      const EdgeInsets.only(top: 8, bottom: 8),
                  child: Text(
                    'No exercises yet — tap "Create new" above.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _repsController,
                      decoration: const InputDecoration(
                        labelText: 'Reps',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _seriesController,
                      decoration: const InputDecoration(
                        labelText: 'Sets',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _canConfirm ? _onConfirm : null,
                  child: const Text('Add'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A quick dialog to create an exercise with just a title.
class _QuickCreateDialog extends StatefulWidget {
  const _QuickCreateDialog();

  @override
  State<_QuickCreateDialog> createState() =>
      _QuickCreateDialogState();
}

class _QuickCreateDialogState extends State<_QuickCreateDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Exercise'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Title',
          hintText: 'e.g. Bench Press',
          border: OutlineInputBorder(),
        ),
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isNotEmpty) {
      Navigator.pop(context, title);
    }
  }
}
