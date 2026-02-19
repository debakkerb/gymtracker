import 'dart:typed_data';

/// A gym exercise with optional description, link, and image.
class Exercise {
  Exercise({
    required this.id,
    required this.title,
    this.description,
    this.externalLink,
    this.imageBytes,
  });

  final String id;
  final String title;
  final String? description;
  final String? externalLink;
  final Uint8List? imageBytes;

  /// Creates a copy with the given fields replaced.
  Exercise copyWith({
    String? title,
    String? Function()? description,
    String? Function()? externalLink,
    Uint8List? Function()? imageBytes,
  }) {
    return Exercise(
      id: id,
      title: title ?? this.title,
      description: description != null ? description() : this.description,
      externalLink: externalLink != null ? externalLink() : this.externalLink,
      imageBytes: imageBytes != null ? imageBytes() : this.imageBytes,
    );
  }
}
