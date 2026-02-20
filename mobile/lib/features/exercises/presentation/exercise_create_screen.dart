import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'exercise_create_view_model.dart';
import 'widgets/exercise_image_picker.dart';

/// Form screen for creating a new exercise.
class ExerciseCreateScreen extends StatefulWidget {
  const ExerciseCreateScreen({required this.viewModel, super.key});

  final ExerciseCreateViewModel viewModel;

  @override
  State<ExerciseCreateScreen> createState() => _ExerciseCreateScreenState();
}

class _ExerciseCreateScreenState extends State<ExerciseCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  ExerciseCreateViewModel get _vm => widget.viewModel;

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    final error = await _vm.save();
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    } else {
      context.go('/exercises');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Exercise')),
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
                    label: const Text('Save Exercise'),
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
