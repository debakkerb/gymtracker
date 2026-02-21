import 'dart:convert';
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

  factory Exercise.fromJson(Map<String, dynamic> json) {
    Uint8List? imageBytes;
    final imageUrl = json['image_url'] as String?;
    if (imageUrl != null && imageUrl.startsWith('data:')) {
      final commaIndex = imageUrl.indexOf(',');
      if (commaIndex != -1) {
        try {
          imageBytes = base64Decode(imageUrl.substring(commaIndex + 1));
        } catch (_) {
          // Invalid base64 — treat as no image.
        }
      }
    }
    return Exercise(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      externalLink: json['external_link'] as String?,
      imageBytes: imageBytes,
    );
  }

  /// Serialises for API create/update requests.
  ///
  /// The [id] field is intentionally omitted — it is assigned by the server.
  /// Images are encoded as `data:<mime>;base64,<data>` URLs.
  Map<String, dynamic> toJson() => {
    'title': title,
    if (description != null) 'description': description,
    if (externalLink != null) 'external_link': externalLink,
    if (imageBytes != null)
      'image_url': 'data:image/jpeg;base64,${base64Encode(imageBytes!)}',
  };

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
