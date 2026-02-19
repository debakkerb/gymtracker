import 'package:flutter/foundation.dart';

import '../../../core/api/api_exception.dart';
import '../data/auth_repository.dart';

/// Manages form state and the registration network call for [RegisterScreen].
class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel({required AuthRepository repository})
    : _repository = repository;

  final AuthRepository _repository;

  static final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  DateTime? _dateOfBirth;
  bool _isLoading = false;

  /// The current password value, used by the confirm-password validator.
  String get password => _password;

  /// The selected date of birth, or `null` if not set.
  DateTime? get dateOfBirth => _dateOfBirth;

  /// Whether a registration request is in flight.
  bool get isLoading => _isLoading;

  /// Whether the form has enough valid data to submit.
  bool get canSubmit =>
      _email.trim().isNotEmpty &&
      _emailRegex.hasMatch(_email.trim()) &&
      _password.length >= 8 &&
      _password == _confirmPassword &&
      !_isLoading;

  set email(String value) {
    _email = value;
    notifyListeners();
  }

  set password(String value) {
    _password = value;
    notifyListeners();
  }

  set confirmPassword(String value) {
    _confirmPassword = value;
    notifyListeners();
  }

  /// Sets the date of birth.
  void setDateOfBirth(DateTime? date) {
    _dateOfBirth = date;
    notifyListeners();
  }

  /// Clears the date of birth.
  void clearDateOfBirth() => setDateOfBirth(null);

  /// Attempts to register and sign in.
  ///
  /// Returns `null` on success, or a human-readable error message on failure.
  /// On success the backend issues a token, [AuthRepository.currentUser] is
  /// updated, and GoRouter's redirect guard navigates to the home screen.
  Future<String?> register() async {
    if (!canSubmit) return 'Please fill in all required fields';
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.register(
        _email.trim(),
        _password,
        dateOfBirth: _dateOfBirth,
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
