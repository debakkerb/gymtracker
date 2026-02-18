import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'exercise_edit_view_model.dart';
import 'widgets/exercise_image_picker.dart';

/// Screen for viewing and editing an existing exercise.
class ExerciseEditScreen extends StatefulWidget {
  const ExerciseEditScreen({
    required this.viewModel,
    super.key,
  });

  final ExerciseEditViewModel viewModel;

  @override
  State<ExerciseEditScreen> createState() =>
      _ExerciseEditScreenState();
}

class _ExerciseEditScreenState extends State<ExerciseEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _linkController;

  ExerciseEditViewModel get _vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    final exercise = _vm.exercise;
    _titleController = TextEditingController(text: exercise.title);
    _descriptionController =
        TextEditingController(text: exercise.description ?? '');
    _linkController =
        TextEditingController(text: exercise.externalLink ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    _vm.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    if (_vm.save()) {
      context.go('/exercises');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Exercise')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListenableBuilder(
            listenable: _vm,
            builder: (context, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExerciseImagePicker(
                  imageBytes: _vm.imageBytes,
                  onImageSelected: _vm.setImage,
                  onImageRemoved: _vm.removeImage,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g. Bench Press',
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
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Optional notes about the exercise',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  onChanged: (value) => _vm.description = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _linkController,
                  decoration: const InputDecoration(
                    labelText: 'External link',
                    hintText: 'https://example.com',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                  ),
                  keyboardType: TextInputType.url,
                  onChanged: (value) => _vm.externalLink = value,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _vm.canSubmit ? _onSave : null,
                    icon: const Icon(Icons.check),
                    label: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
