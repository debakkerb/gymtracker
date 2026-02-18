import 'package:flutter/foundation.dart';

import '../data/auth_repository.dart';

/// Manages form state for the login screen.
class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required AuthRepository repository})
    : _repository = repository;

  final AuthRepository _repository;

  String _email = '';
  String _password = '';

  /// Whether the form has enough data to attempt login.
  bool get canSubmit => _email.trim().isNotEmpty && _password.isNotEmpty;

  set email(String value) {
    _email = value;
    notifyListeners();
  }

  set password(String value) {
    _password = value;
    notifyListeners();
  }

  /// Attempts to log in.
  ///
  /// Returns `null` on success, or an error message on failure.
  String? login() {
    if (!canSubmit) return 'Please fill in all fields';
    return _repository.login(_email.trim(), _password);
  }
}
