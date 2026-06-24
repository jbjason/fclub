import 'package:hive_flutter/hive_flutter.dart';

import '../model/pack_session.dart';
import '../pack_check_hive_boxes.dart';

/// Local persistence layer for [PackSession] data via Hive.
class PackCheckRepository {
  Box<PackSession> get _box =>
      Hive.box<PackSession>(PackCheckHiveBoxes.sessionsBox);

  /// Returns the single non-completed session, or null if none exists.
  PackSession? loadActiveSession() {
    final active = _box.values.where((s) => !s.isCompleted).toList();
    if (active.isEmpty) return null;
    active.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return active.first;
  }

  /// Returns all completed sessions sorted newest first.
  List<PackSession> loadCompletedSessions() {
    return _box.values.where((s) => s.isCompleted).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveSession(PackSession session) =>
      _box.put(session.id, session);

  Future<void> deleteSession(String id) => _box.delete(id);

  Future<void> clearHistory() async {
    final completed = _box.values.where((s) => s.isCompleted).toList();
    for (final s in completed) {
      await _box.delete(s.id);
    }
  }
}
