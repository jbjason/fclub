import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_animal_part.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_event.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_expense.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_failure.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_firestore_mapper.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_participant.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_project.dart';
import 'package:fclub/feature/kurbani/data/repositories/kurbani_repository.dart';

class FirestoreKurbaniRepository implements KurbaniRepository {
  FirestoreKurbaniRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String projectDocumentId = 'kurbani';

  DocumentReference<Map<String, dynamic>> _group(String groupId) =>
      _firestore.collection('groups').doc(groupId);

  DocumentReference<Map<String, dynamic>> _project(String groupId) =>
      _group(groupId).collection('projects').doc(projectDocumentId);

  CollectionReference<Map<String, dynamic>> _events(String groupId) =>
      _project(groupId).collection('events');

  DocumentReference<Map<String, dynamic>> _event(
    String groupId,
    String eventId,
  ) => _events(groupId).doc(eventId);

  CollectionReference<Map<String, dynamic>> _eventCollection(
    String groupId,
    String eventId,
    String name,
  ) => _event(groupId, eventId).collection(name);

  @override
  Future<KurbaniProject?> findProject({required String groupId}) async {
    try {
      return KurbaniFirestoreMapper.project(await _project(groupId).get());
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<String?> getGroupAdminId({required String groupId}) async {
    try {
      final data = (await _group(groupId).get()).data();
      final value = data?['createdBy'];
      return value is String && value.trim().isNotEmpty ? value.trim() : null;
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<KurbaniProject> createProject({
    required String groupId,
    required String name,
    required String adminId,
  }) async {
    final group = _group(groupId);
    final project = _project(groupId);
    try {
      await _firestore.runTransaction((transaction) async {
        final groupSnapshot = await transaction.get(group);
        if (!groupSnapshot.exists ||
            groupSnapshot.data()?['createdBy'] != adminId) {
          throw const KurbaniFailure('kurbani_error_group_admin_create');
        }
        if ((await transaction.get(project)).exists) {
          throw const KurbaniFailure('kurbani_error_project_exists');
        }
        transaction.set(
          project,
          createProjectData(
            name: name,
            adminId: adminId,
            createdAt: FieldValue.serverTimestamp(),
          ),
        );
      });
      return KurbaniProject(
        id: projectDocumentId,
        name: name.trim(),
        adminId: adminId,
        status: KurbaniProjectStatus.active,
        createdAt: DateTime.now(),
      );
    } on KurbaniFailure {
      rethrow;
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Stream<KurbaniProject?> watchProject({required String groupId}) async* {
    try {
      await for (final snapshot in _project(groupId).snapshots()) {
        yield KurbaniFirestoreMapper.project(snapshot);
      }
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Stream<List<KurbaniEvent>> watchEvents({required String groupId}) async* {
    try {
      await for (final snapshot in _events(groupId).snapshots()) {
        final events = snapshot.docs
            .map(KurbaniFirestoreMapper.event)
            .toList(growable: false);
        yield events.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Stream<KurbaniEvent?> watchEvent({
    required String groupId,
    required String eventId,
  }) async* {
    try {
      await for (final snapshot in _event(groupId, eventId).snapshots()) {
        yield KurbaniFirestoreMapper.eventOrNull(snapshot);
      }
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<List<KurbaniParticipant>> getGroupMembers({
    required String groupId,
  }) async {
    try {
      final snapshot = await _group(groupId).collection('members').get();
      final members = snapshot.docs
          .map(KurbaniFirestoreMapper.participant)
          .toList(growable: false);
      return members.toList()..sort(_byParticipantName);
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<KurbaniEvent> createEvent({
    required String groupId,
    required String name,
    required List<String> participantIds,
    required double contribution,
  }) async {
    final event = _events(groupId).doc();
    try {
      final memberSnapshots = await Future.wait(
        participantIds.map(
          (id) => _group(groupId).collection('members').doc(id).get(),
        ),
      );
      if (memberSnapshots.any((snapshot) => !snapshot.exists)) {
        throw const KurbaniFailure('kurbani_error_member_missing');
      }
      final batch = _firestore.batch();
      batch.set(event, {
        'name': name.trim(),
        'status': KurbaniEventStatus.active.value,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      for (final member in memberSnapshots) {
        final data = member.data() ?? const <String, dynamic>{};
        batch.set(event.collection('participants').doc(member.id), {
          'username': _first(data, const ['username', 'displayName']),
          'email': _first(data, const ['email']).toLowerCase(),
          'profilePic': _first(data, const ['profilePic', 'photoUrl']),
          'contribution': contribution,
          'paidStatus': KurbaniPaidStatus.pending.value,
          'joinedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      final now = DateTime.now();
      return KurbaniEvent(
        id: event.id,
        name: name.trim(),
        status: KurbaniEventStatus.active,
        createdAt: now,
        updatedAt: now,
      );
    } on KurbaniFailure {
      rethrow;
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> updateEventStatus({
    required String groupId,
    required String eventId,
    required KurbaniEventStatus status,
  }) async {
    try {
      await _event(groupId, eventId).update({
        'status': status.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> deleteEvent({
    required String groupId,
    required String eventId,
  }) async {
    try {
      for (final name in const ['participants', 'expenses', 'animalParts']) {
        final documents = await _eventCollection(groupId, eventId, name).get();
        await _deleteDocuments(documents.docs);
      }
      await _event(groupId, eventId).delete();
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Stream<List<KurbaniParticipant>> watchParticipants({
    required String groupId,
    required String eventId,
  }) => _watchList(
    _eventCollection(groupId, eventId, 'participants'),
    KurbaniFirestoreMapper.participant,
    (items) => items..sort(_byParticipantName),
  );

  @override
  Future<List<KurbaniParticipant>> getAvailableParticipants({
    required String groupId,
    required String eventId,
  }) async {
    try {
      final current = await _eventCollection(
        groupId,
        eventId,
        'participants',
      ).get();
      final currentIds = current.docs.map((document) => document.id).toSet();
      final members = await getGroupMembers(groupId: groupId);
      return members
          .where((member) => !currentIds.contains(member.id))
          .toList(growable: false);
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> addParticipant({
    required String groupId,
    required String eventId,
    required String userId,
    required double contribution,
  }) async {
    try {
      final member = await _group(
        groupId,
      ).collection('members').doc(userId).get();
      final data = member.data();
      if (!member.exists || data == null) {
        throw const KurbaniFailure('kurbani_error_member_missing');
      }
      final participant = _eventCollection(
        groupId,
        eventId,
        'participants',
      ).doc(userId);
      final batch = _firestore.batch();
      batch.set(participant, {
        'username': _first(data, const ['username', 'displayName']),
        'email': _first(data, const ['email']).toLowerCase(),
        'profilePic': _first(data, const ['profilePic', 'photoUrl']),
        'contribution': contribution,
        'paidStatus': KurbaniPaidStatus.pending.value,
        'joinedAt': FieldValue.serverTimestamp(),
      });
      _touchEvent(batch, groupId, eventId);
      await batch.commit();
    } on KurbaniFailure {
      rethrow;
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> updateParticipant({
    required String groupId,
    required String eventId,
    required String userId,
    required double contribution,
    required KurbaniPaidStatus paidStatus,
  }) async {
    try {
      final participant = _eventCollection(
        groupId,
        eventId,
        'participants',
      ).doc(userId);
      final batch = _firestore.batch();
      batch.update(participant, {
        'contribution': contribution,
        'paidStatus': paidStatus.value,
      });
      _touchEvent(batch, groupId, eventId);
      await batch.commit();
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> removeParticipant({
    required String groupId,
    required String eventId,
    required String userId,
  }) async {
    try {
      final participant = _eventCollection(
        groupId,
        eventId,
        'participants',
      ).doc(userId);
      final batch = _firestore.batch();
      batch.delete(participant);
      _touchEvent(batch, groupId, eventId);
      await batch.commit();
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Stream<List<KurbaniExpense>> watchExpenses({
    required String groupId,
    required String eventId,
  }) => _watchList(
    _eventCollection(groupId, eventId, 'expenses'),
    KurbaniFirestoreMapper.expense,
    (items) => items..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
  );

  @override
  Future<void> createExpense({
    required String groupId,
    required String eventId,
    required String title,
    required double amount,
    required String paidByMemberId,
    required String createdBy,
    String? note,
  }) async {
    try {
      final expense = _eventCollection(groupId, eventId, 'expenses').doc();
      final batch = _firestore.batch();
      batch.set(expense, {
        'title': title.trim(),
        'amount': amount,
        'paidByMemberId': paidByMemberId,
        'note': _nullable(note),
        'createdBy': createdBy,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _touchEvent(batch, groupId, eventId);
      await batch.commit();
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> deleteExpense({
    required String groupId,
    required String eventId,
    required String expenseId,
  }) async {
    try {
      final expense = _eventCollection(
        groupId,
        eventId,
        'expenses',
      ).doc(expenseId);
      final batch = _firestore.batch();
      batch.delete(expense);
      _touchEvent(batch, groupId, eventId);
      await batch.commit();
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Stream<List<KurbaniAnimalPart>> watchAnimalParts({
    required String groupId,
    required String eventId,
  }) => _watchList(
    _eventCollection(groupId, eventId, 'animalParts'),
    KurbaniFirestoreMapper.animalPart,
    (items) => items..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
  );

  @override
  Future<void> createAnimalPart({
    required String groupId,
    required String eventId,
    required String name,
    required double weightKg,
    required String createdBy,
    String? assignedToUid,
    String? note,
  }) async {
    try {
      final part = _eventCollection(groupId, eventId, 'animalParts').doc();
      final batch = _firestore.batch();
      batch.set(part, {
        'name': name.trim(),
        'weightKg': weightKg,
        'assignedToUid': _nullable(assignedToUid),
        'note': _nullable(note),
        'createdBy': createdBy,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _touchEvent(batch, groupId, eventId);
      await batch.commit();
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> deleteAnimalPart({
    required String groupId,
    required String eventId,
    required String partId,
  }) async {
    try {
      final part = _eventCollection(
        groupId,
        eventId,
        'animalParts',
      ).doc(partId);
      final batch = _firestore.batch();
      batch.delete(part);
      _touchEvent(batch, groupId, eventId);
      await batch.commit();
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  Stream<List<T>> _watchList<T>(
    CollectionReference<Map<String, dynamic>> collection,
    T Function(DocumentSnapshot<Map<String, dynamic>>) mapper,
    List<T> Function(List<T>) sort,
  ) async* {
    try {
      await for (final snapshot in collection.snapshots()) {
        yield sort(snapshot.docs.map(mapper).toList(growable: true));
      }
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  Future<void> _deleteDocuments(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
  ) async {
    for (var start = 0; start < documents.length; start += 450) {
      final batch = _firestore.batch();
      final end = (start + 450).clamp(0, documents.length);
      for (final document in documents.sublist(start, end)) {
        batch.delete(document.reference);
      }
      await batch.commit();
    }
  }

  void _touchEvent(WriteBatch batch, String groupId, String eventId) {
    batch.update(_event(groupId, eventId), {
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Map<String, Object> createProjectData({
    required String name,
    required String adminId,
    required Object createdAt,
  }) => {
    'name': name.trim(),
    'adminId': adminId,
    'status': KurbaniProjectStatus.active.value,
    'createdAt': createdAt,
  };

  static int _byParticipantName(KurbaniParticipant a, KurbaniParticipant b) =>
      a.username.toLowerCase().compareTo(b.username.toLowerCase());

  String _first(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }

  Object? _nullable(String? value) {
    final text = value?.trim();
    return text == null || text.isEmpty ? null : text;
  }

  KurbaniFailure _failure(FirebaseException error) {
    final key = switch (error.code) {
      'permission-denied' => 'kurbani_error_permission',
      'unavailable' || 'deadline-exceeded' => 'kurbani_error_offline',
      _ => 'kurbani_error_firestore',
    };
    return KurbaniFailure(key, error);
  }
}
