import 'package:flutter/foundation.dart';

import '../../../core/api/api_exception.dart';
import '../data/auth_repository.dart';

/// Manages form state and the login network call for [LoginScreen].
class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required AuthRepository repository})
    : _repository = repository;

  final AuthRepository _repository;

  String _email = '';
  String _password = '';
  bool _isLoading = false;

  /// Whether the form is ready to submit.
  bool get canSubmit =>
      _email.trim().isNotEmpty && _password.isNotEmpty && !_isLoading;

  /// Whether a login request is in flight.
  bool get isLoading => _isLoading;

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
  /// Returns `null` on success, or a human-readable error message on failure.
  /// On success [AuthRepository.currentUser] is updated, which triggers
  /// GoRouter's redirect guard automatically.
  Future<String?> login() async {
    if (!canSubmit) return 'Please fill in all fields';
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.login(_email.trim(), _password);
      return null;
    } on ApiException catch (e) {
      return e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
