import 'package:flutter/material.dart';

import '../domain/session_record.dart';
import 'session_history_view_model.dart';
import 'widgets/session_record_card.dart';

/// Displays a list of completed workout sessions.
class SessionHistoryScreen extends StatelessWidget {
  const SessionHistoryScreen({required this.viewModel, super.key});

  final SessionHistoryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: ValueListenableBuilder<List<SessionRecord>>(
        valueListenable: viewModel.records,
        builder: (context, records, _) {
          if (records.isEmpty) {
            return const _EmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: records.length,
            itemBuilder: (context, index) =>
                SessionRecordCard(record: records[index]),
          );
        },
      ),
    );
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
            Icons.history,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No sessions yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Complete a workout to see it here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
