import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Allows the user to pick, preview, and remove an image.
class ExerciseImagePicker extends StatelessWidget {
  const ExerciseImagePicker({
    required this.imageBytes,
    required this.onImageSelected,
    required this.onImageRemoved,
    super.key,
  });

  final Uint8List? imageBytes;
  final ValueChanged<Uint8List> onImageSelected;
  final VoidCallback onImageRemoved;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    onImageSelected(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bytes = imageBytes;

    if (bytes != null) {
      return _ImagePreview(
        bytes: bytes,
        onRemove: onImageRemoved,
      );
    }

    return _ImagePlaceholder(
      colorScheme: colorScheme,
      onTap: _pickImage,
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.bytes,
    required this.onRemove,
  });

  final Uint8List bytes;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            bytes,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton.filledTonal(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onRemove,
            tooltip: 'Remove image',
            style: IconButton.styleFrom(
              minimumSize: const Size(32, 32),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    required this.colorScheme,
    required this.onTap,
  });

  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              'Add image',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
