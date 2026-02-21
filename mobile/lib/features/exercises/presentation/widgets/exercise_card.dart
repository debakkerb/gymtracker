import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/exercise.dart';

/// An expandable card that shows exercise details on tap.
///
/// Tapping expands to reveal the description and a link to the
/// edit screen. The delete button is always visible.
class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    required this.exercise,
    required this.onDelete,
    super.key,
  });

  final Exercise exercise;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: _Avatar(exercise: exercise),
        title: Text(exercise.title),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (exercise.imageBytes != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      exercise.imageBytes!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (exercise.description != null) ...[
                  Text(exercise.description!, style: textTheme.bodyMedium),
                  const SizedBox(height: 12),
                ],
                if (exercise.externalLink != null) ...[
                  Row(
                    children: [
                      Icon(Icons.link, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          exercise.externalLink!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => context.go('/exercises/${exercise.id}'),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline,
                        color: colorScheme.error,
                      ),
                      label: Text(
                        'Delete',
                        style: TextStyle(color: colorScheme.error),
                      ),
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

class _Avatar extends StatelessWidget {
  const _Avatar({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bytes = exercise.imageBytes;

    if (bytes != null) {
      return CircleAvatar(backgroundImage: MemoryImage(bytes));
    }
    return CircleAvatar(
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        exercise.title.characters.first.toUpperCase(),
        style: TextStyle(color: colorScheme.onPrimaryContainer),
      ),
    );
  }
}
