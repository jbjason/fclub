import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../data/default_pack_items.dart';
import '../../data/model/pack_item.dart';
import '../../data/model/pack_session.dart';
import '../../data/repository/pack_check_repository.dart';

/// Drives all state for the PackCheck feature.
///
/// **Session lifecycle:**
/// 1. [startDraft] — creates an in-memory draft; nothing is written to Hive.
/// 2. User selects items on the draft (toggles work on the draft only).
/// 3. [confirmDraft] — persists the draft to Hive for the first time and
///    transitions to check mode. This is the only moment a session "exists".
/// 4. User ticks items off in check mode.
/// 5. [completeSession] — marks the saved session complete and moves it to
///    [history]. A new session can then be started.
///
/// A session that is never confirmed is simply discarded via [discardDraft].
class PackCheckProvider extends ChangeNotifier {
  PackCheckProvider(this._repo) {
    _load();
  }

  final PackCheckRepository _repo;
  final _uuid = const Uuid();
  final _picker = ImagePicker();

  PackSession? _activeSession; // persisted, non-completed
  PackSession? _draftSession; // in-memory only, not yet saved
  List<PackSession> _history = [];
  bool _isCheckMode = false;
  bool _isDraftMode = false;

  // ── Public getters ────────────────────────────────────────────────────────

  /// The draft if one is in progress, otherwise the persisted active session.
  PackSession? get activeSession =>
      _isDraftMode ? _draftSession : _activeSession;

  List<PackSession> get history => List.unmodifiable(_history);

  bool get isCheckMode => _isCheckMode;

  /// True while working on an unsaved draft (Step 1 before first confirmation).
  bool get isDraftMode => _isDraftMode;

  bool get hasActiveSession => activeSession != null;

  /// A new session can only be started when no active or draft session exists.
  bool get canCreateNew => _activeSession == null && !_isDraftMode;

  bool get hasPackedItems => (activeSession?.packedCount ?? 0) > 0;

  // ── Init ──────────────────────────────────────────────────────────────────

  void _load() {
    _activeSession = _repo.loadActiveSession();
    _history = _repo.loadCompletedSessions();
    notifyListeners();
  }

  // ── Draft management ──────────────────────────────────────────────────────

  /// Creates a draft in memory. Nothing is written to Hive yet.
  void startDraft(String name) {
    if (!canCreateNew) return;
    _draftSession = PackSession(
      id: _uuid.v4(),
      name: name.trim().isEmpty ? 'My Trip' : name.trim(),
      createdAt: DateTime.now(),
      items: DefaultPackItems.catalog,
    );
    _isDraftMode = true;
    _isCheckMode = false;
    notifyListeners();
  }

  /// Discards the draft without saving anything.
  void discardDraft() {
    _draftSession = null;
    _isDraftMode = false;
    _isCheckMode = false;
    notifyListeners();
  }

  /// Saves the draft to Hive for the first time and enters check mode.
  ///
  /// Called when the user taps "Confirm & Start Checking" in Step 1.
  Future<void> confirmDraft() async {
    final draft = _draftSession;
    if (draft == null) return;
    await _repo.saveSession(draft);
    _activeSession = draft;
    _draftSession = null;
    _isDraftMode = false;
    _isCheckMode = true;
    notifyListeners();
  }

  // ── Mode toggle ───────────────────────────────────────────────────────────

  void enterCheckMode() {
    _isCheckMode = true;
    notifyListeners();
  }

  void enterPackMode() {
    _isCheckMode = false;
    notifyListeners();
  }

  // ── Item interactions ─────────────────────────────────────────────────────

  /// Toggles [isPacked] on the active or draft session.
  ///
  /// Draft changes are kept in memory only; persisted sessions are saved immediately.
  Future<void> togglePacked(String itemId) async {
    final session = activeSession;
    if (session == null) return;
    final idx = session.items.indexWhere((i) => i.id == itemId);
    if (idx == -1) return;
    final item = session.items[idx];
    session.items[idx] = item.copyWith(
      isPacked: !item.isPacked,
      isCheckedBack: item.isPacked ? false : item.isCheckedBack,
    );
    if (!_isDraftMode) await _repo.saveSession(session);
    notifyListeners();
  }

  Future<void> toggleCheckedBack(String itemId) async {
    final session = _activeSession;
    if (session == null) return;
    final idx = session.items.indexWhere((i) => i.id == itemId);
    if (idx == -1) return;
    final item = session.items[idx];
    session.items[idx] = item.copyWith(isCheckedBack: !item.isCheckedBack);
    await _repo.saveSession(session);
    notifyListeners();
  }

  // ── Custom item creation ──────────────────────────────────────────────────

  Future<void> addCustomItem({
    required String name,
    required IconData icon,
  }) async {
    final session = activeSession;
    if (session == null) return;
    session.items.add(PackItem(
      id: _uuid.v4(),
      name: name.trim(),
      iconCodePoint: icon.codePoint,
      isCustom: true,
    ));
    if (!_isDraftMode) await _repo.saveSession(session);
    notifyListeners();
  }

  Future<void> addPhotoItem({
    required String name,
    required ImageSource source,
  }) async {
    final session = activeSession;
    if (session == null) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 70);
    if (picked == null) return;
    session.items.add(PackItem(
      id: _uuid.v4(),
      name: name.trim().isEmpty ? 'Custom' : name.trim(),
      iconCodePoint: Icons.image.codePoint,
      imagePath: picked.path,
      isCustom: true,
    ));
    if (!_isDraftMode) await _repo.saveSession(session);
    notifyListeners();
  }

  Future<void> removeCustomItem(String itemId) async {
    final session = activeSession;
    if (session == null) return;
    session.items.removeWhere((i) => i.id == itemId && i.isCustom);
    if (!_isDraftMode) await _repo.saveSession(session);
    notifyListeners();
  }

  // ── Session completion ────────────────────────────────────────────────────

  /// Marks the active session complete and moves it to [history].
  Future<void> completeSession() async {
    final session = _activeSession;
    if (session == null) return;
    session.isCompleted = true;
    for (final item in session.items) {
      item.isCheckedBack = false;
    }
    await _repo.saveSession(session);
    _isCheckMode = false;
    _load();
  }

  // ── History management ────────────────────────────────────────────────────

  Future<void> clearHistory() async {
    await _repo.clearHistory();
    _load();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  File? photoFile(PackItem item) =>
      item.imagePath != null ? File(item.imagePath!) : null;
}
