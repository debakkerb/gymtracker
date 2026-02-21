import 'package:flutter/material.dart';

/// A decorative fitness-themed hero banner.
///
/// Renders a network image with a gradient overlay and optional text.
/// Falls back to a styled gradient container when the image cannot load.
class FitnessHeroBanner extends StatelessWidget {
  const FitnessHeroBanner({
    required this.title,
    this.subtitle,
    this.height = 200,
    super.key,
  });

  final String title;
  final String? subtitle;

  /// The height of the banner in logical pixels.
  final double height;

  static const _imageUrl =
      'https://images.unsplash.com/photo-1534438327276-14e5300c3a48'
      '?w=800&q=80&auto=format&fit=crop';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return _GradientPlaceholder(colorScheme: colorScheme);
            },
            errorBuilder: (context, error, stackTrace) =>
                _GradientPlaceholder(colorScheme: colorScheme),
          ),
          // Gradient overlay so text is always legible.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x1A000000), Color(0x99000000)],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: const [
                      Shadow(blurRadius: 4, color: Colors.black54),
                    ],
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      shadows: const [
                        Shadow(blurRadius: 4, color: Colors.black54),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientPlaceholder extends StatelessWidget {
  const _GradientPlaceholder({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primaryContainer, colorScheme.tertiaryContainer],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.fitness_center,
          size: 64,
          color: colorScheme.onPrimaryContainer.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
