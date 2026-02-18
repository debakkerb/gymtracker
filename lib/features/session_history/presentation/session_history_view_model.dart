import 'package:flutter/foundation.dart';

import '../data/session_history_repository.dart';
import '../domain/session_record.dart';

/// Exposes session history records for the UI.
class SessionHistoryViewModel {
  SessionHistoryViewModel({required SessionHistoryRepository repository})
    : _repository = repository;

  final SessionHistoryRepository _repository;

  /// A listenable list of completed sessions,
  /// ordered newest-first.
  ValueListenable<List<SessionRecord>> get records => _repository.records;
}
