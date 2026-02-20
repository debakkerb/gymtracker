import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';
import '../domain/session_record.dart';

/// Remote-backed store for completed session records.
///
/// [add] optimistically prepends the record to the local list before the
/// network call completes, so the history screen updates immediately after
/// a workout finishes.
class SessionHistoryRepository {
  SessionHistoryRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;
  final _records = ValueNotifier<List<SessionRecord>>([]);

  /// A listenable snapshot of all session records, ordered newest-first.
  ValueListenable<List<SessionRecord>> get records => _records;

  /// Fetches the current user's session history from the server.
  Future<void> load() async {
    final data = await _api.get('/sessions') as List<dynamic>;
    _records.value = data
        .map((e) => SessionRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Clears the local list without a network call (used on logout).
  void clear() => _records.value = [];

  /// Persists [record] to the server and prepends it to the local list.
  ///
  /// The local list is updated immediately (before the network round-trip)
  /// so the history screen reflects the new session without delay.
  Future<void> add(SessionRecord record) async {
    _records.value = [record, ..._records.value];
    await _api.post('/sessions', body: record.toJson());
  }
}
