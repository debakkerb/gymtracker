import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_exception.dart';
import '../data/exercise_repository.dart';
import '../domain/exercise.dart';

/// Manages the form state for creating a new exercise.
class ExerciseCreateViewModel extends ChangeNotifier {
  ExerciseCreateViewModel({required ExerciseRepository repository})
    : _repository = repository;

  final ExerciseRepository _repository;
  static const _uuid = Uuid();

  String _title = '';
  String _description = '';
  String _externalLink = '';
  Uint8List? _imageBytes;
  bool _isLoading = false;

  /// The selected image bytes, or `null` if none.
  Uint8List? get imageBytes => _imageBytes;

  /// Whether the form has enough data to submit.
  bool get canSubmit => _title.trim().isNotEmpty && !_isLoading;

  set title(String value) {
    _title = value;
    notifyListeners();
  }

  set description(String value) {
    _description = value;
    notifyListeners();
  }

  set externalLink(String value) {
    _externalLink = value;
    notifyListeners();
  }

  /// Sets the picked image bytes.
  void setImage(Uint8List? bytes) {
    _imageBytes = bytes;
    notifyListeners();
  }

  /// Removes the currently selected image.
  void removeImage() => setImage(null);

  /// Saves the exercise to the server.
  ///
  /// Returns `null` on success, or a human-readable error message on failure.
  Future<String?> save() async {
    if (!canSubmit) return null;
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.add(
        Exercise(
          id: _uuid.v4(),
          title: _title.trim(),
          description: _description.trim().isEmpty ? null : _description.trim(),
          externalLink: _externalLink.trim().isEmpty
              ? null
              : _externalLink.trim(),
          imageBytes: _imageBytes,
        ),
      );
      return null;
    } on ApiException catch (e) {
      return e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
