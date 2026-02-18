import 'package:flutter/material.dart';

/// A circular countdown display showing remaining rest time.
class RestTimerWidget extends StatelessWidget {
  const RestTimerWidget({
    required this.remainingSeconds,
    required this.totalSeconds,
    super.key,
  });

  /// Seconds left on the timer.
  final int remainingSeconds;

  /// Total rest duration for calculating progress.
  final int totalSeconds;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;

    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final label =
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: colorScheme.primary,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
