import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/auth_repository.dart';
import '../domain/user.dart';

/// Manages form state for the registration screen.
class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel({required AuthRepository repository})
    : _repository = repository;

  final AuthRepository _repository;
  static const _uuid = Uuid();

  static final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  DateTime? _dateOfBirth;

  /// The current password value, used by the confirm validator.
  String get password => _password;

  /// The selected date of birth, or `null` if not set.
  DateTime? get dateOfBirth => _dateOfBirth;

  /// Whether the form has enough valid data to submit.
  bool get canSubmit =>
      _email.trim().isNotEmpty &&
      _emailRegex.hasMatch(_email.trim()) &&
      _password.length >= 8 &&
      _password == _confirmPassword;

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

  /// Attempts to register the user.
  ///
  /// Returns `null` on success, or an error message on failure.
  String? register() {
    if (!canSubmit) return 'Please fill in all required fields';

    final email = _email.trim().toLowerCase();
    if (_repository.findByEmail(email) != null) {
      return 'This email is already registered';
    }

    _repository.add(
      User(
        id: _uuid.v4(),
        email: email,
        password: _password,
        dateOfBirth: _dateOfBirth,
      ),
    );
    return null;
  }
}
