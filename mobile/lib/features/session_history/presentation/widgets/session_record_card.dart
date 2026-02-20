import 'package:flutter/material.dart';

import '../../domain/session_record.dart';

/// Formats [d] as a short human-readable string, e.g. "43 min" or "1h 5min".
String _formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  if (h > 0) return '${h}h ${m}min';
  if (m > 0) return '$m min';
  return '${d.inSeconds}s';
}

/// An expandable card that summarises a completed session.
class SessionRecordCard extends StatelessWidget {
  const SessionRecordCard({required this.record, super.key});

  final SessionRecord record;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = MaterialLocalizations.of(context);
    final formattedDate = localizations.formatMediumDate(record.date);
    final formattedDuration = _formatDuration(record.duration);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            record.workoutTitle.characters.first.toUpperCase(),
            style: TextStyle(color: colorScheme.onPrimaryContainer),
          ),
        ),
        title: Text(record.workoutTitle),
        subtitle: Text(
          '$formattedDate \u00b7 $formattedDuration',
          style: textTheme.bodySmall,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...record.exercises.map(
                  (exercise) => Padding(
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
                            exercise.exerciseName,
                            style: textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          '${exercise.repetitions} reps'
                          ' \u00d7 '
                          '${exercise.series} sets',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
