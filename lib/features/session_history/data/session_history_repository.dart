import 'package:flutter/foundation.dart';

import '../domain/session_record.dart';

/// In-memory storage for completed session records.
///
/// Exposes a [ValueNotifier] so the UI can rebuild reactively
/// whenever a new session is saved.
class SessionHistoryRepository {
  final _records = ValueNotifier<List<SessionRecord>>([]);

  /// A listenable snapshot of all session records,
  /// ordered newest-first.
  ValueListenable<List<SessionRecord>> get records => _records;

  /// Adds [record] to the store and notifies listeners.
  void add(SessionRecord record) {
    _records.value = [record, ..._records.value];
  }
}
