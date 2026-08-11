import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fclub/feature/tour/data/models/tour_event.dart';
import 'package:fclub/feature/tour/data/models/tour_expense.dart';
import 'package:fclub/feature/tour/data/models/tour_failure.dart';
import 'package:fclub/feature/tour/data/models/tour_firestore_mapper.dart';
import 'package:fclub/feature/tour/data/models/tour_extra_payment.dart';
import 'package:fclub/feature/tour/data/models/tour_participant.dart';
import 'package:fclub/feature/tour/data/models/tour_project.dart';
import 'package:fclub/feature/tour/data/repositories/tour_repository.dart';
import 'package:fclub/feature/tour/data/services/tour_calculator.dart';

class FirestoreTourRepository implements TourRepository {
  FirestoreTourRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String projectDocumentId = 'tour';

  final FirebaseFirestore _firestore;

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
  Future<TourProject?> findProject({required String groupId}) async {
    try {
      return TourFirestoreMapper.project(await _project(groupId).get());
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<String?> getGroupAdminId({required String groupId}) async {
    try {
      final value = (await _group(groupId).get()).data()?['createdBy'];
      return value is String && value.trim().isNotEmpty ? value.trim() : null;
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<TourProject> createProject({
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
          throw const TourFailure('tour_error_group_admin_create');
        }
        if ((await transaction.get(project)).exists) {
          throw const TourFailure('tour_error_project_exists');
        }
        transaction.set(
          project,
          createProjectData(
            name: name,
            adminId: adminId,
            createdAt: FieldValue.serverTimestamp(),
            updatedAt: FieldValue.serverTimestamp(),
          ),
        );
      });
      final now = DateTime.now();
      return TourProject(
        id: projectDocumentId,
        name: name.trim(),
        adminId: adminId,
        createdAt: now,
        updatedAt: now,
      );
    } on TourFailure {
      rethrow;
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Stream<TourProject?> watchProject({required String groupId}) async* {
    try {
      await for (final snapshot in _project(groupId).snapshots()) {
        yield TourFirestoreMapper.project(snapshot);
      }
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Stream<List<TourEvent>> watchEvents({required String groupId}) async* {
    try {
      await for (final snapshot in _events(groupId).snapshots()) {
        final events =
            snapshot.docs.map(TourFirestoreMapper.event).toList(growable: true)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        yield events;
      }
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Stream<TourEvent?> watchEvent({
    required String groupId,
    required String eventId,
  }) async* {
    try {
      await for (final snapshot in _event(groupId, eventId).snapshots()) {
        yield TourFirestoreMapper.eventOrNull(snapshot);
      }
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<List<TourParticipantCandidate>> getGroupMembers({
    required String groupId,
  }) async {
    try {
      final snapshot = await _group(groupId).collection('members').get();
      final members =
          snapshot.docs
              .map(TourFirestoreMapper.candidate)
              .toList(growable: true)
            ..sort(_byCandidateName);
      return members;
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<TourEvent> createEvent({
    required String groupId,
    required String tourName,
    required double decidedBudget,
    required String createdBy,
    required List<String> participantIds,
  }) async {
    final event = _events(groupId).doc();
    try {
      final openEvents = await _events(groupId)
          .where(
            'status',
            whereIn: [
              TourEventStatus.planning.value,
              TourEventStatus.active.value,
            ],
          )
          .limit(1)
          .get();
      if (openEvents.docs.isNotEmpty) {
        throw const TourFailure('tour_error_active_event_exists');
      }

      final uniqueIds = participantIds.toSet().toList(growable: false);
      final memberSnapshots = await Future.wait(
        uniqueIds.map(
          (id) => _group(groupId).collection('members').doc(id).get(),
        ),
      );
      if (memberSnapshots.isEmpty ||
          memberSnapshots.any((snapshot) => !snapshot.exists)) {
        throw const TourFailure('tour_error_member_missing');
      }

      final contribution = TourCalculator.equalContribution(
        totalBudget: decidedBudget,
        participantCount: memberSnapshots.length,
      );
      await _createEventDocuments(
        groupId: groupId,
        event: event,
        tourName: tourName,
        decidedBudget: decidedBudget,
        createdBy: createdBy,
        contribution: contribution,
        members: memberSnapshots,
      );
      final now = DateTime.now();
      return TourEvent(
        id: event.id,
        tourName: tourName.trim(),
        decidedBudget: decidedBudget,
        status: TourEventStatus.active,
        createdBy: createdBy,
        createdAt: now,
        updatedAt: now,
        completedAt: null,
      );
    } on TourFailure {
      rethrow;
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> updateEventBudget({
    required String groupId,
    required String eventId,
    required double decidedBudget,
  }) async {
    try {
      final participants = await _eventCollection(
        groupId,
        eventId,
        'participants',
      ).get();
      if (participants.docs.isEmpty) {
        throw const TourFailure('tour_error_last_member');
      }
      await _updateBudgetDocuments(
        groupId: groupId,
        eventId: eventId,
        decidedBudget: decidedBudget,
        participants: participants.docs,
      );
    } on TourFailure {
      rethrow;
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> updateEventStatus({
    required String groupId,
    required String eventId,
    required TourEventStatus status,
  }) async {
    try {
      final batch = _firestore.batch();
      batch.update(_event(groupId, eventId), {
        'status': status.value,
        'updatedAt': FieldValue.serverTimestamp(),
        'completedAt': status == TourEventStatus.completed
            ? FieldValue.serverTimestamp()
            : null,
      });
      _touchProject(batch, groupId);
      await batch.commit();
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
      for (final name in const ['participants', 'expenses', 'extraPayments']) {
        final documents = await _eventCollection(groupId, eventId, name).get();
        await _deleteDocuments(documents.docs);
      }
      final batch = _firestore.batch();
      batch.delete(_event(groupId, eventId));
      _touchProject(batch, groupId);
      await batch.commit();
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Stream<List<TourParticipant>> watchParticipants({
    required String groupId,
    required String eventId,
  }) => _watchList(
    _eventCollection(groupId, eventId, 'participants'),
    TourFirestoreMapper.participant,
    (items) => items..sort(_byParticipantName),
  );

  @override
  Future<List<TourParticipantCandidate>> getAvailableParticipants({
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
  }) async {
    try {
      final member = await _group(
        groupId,
      ).collection('members').doc(userId).get();
      final data = member.data();
      if (!member.exists || data == null) {
        throw const TourFailure('tour_error_member_missing');
      }
      final batch = _firestore.batch();
      batch.set(
        _eventCollection(groupId, eventId, 'participants').doc(userId),
        {
          'id': userId,
          'username': _first(data, const ['username', 'displayName']),
          'email': _first(data, const ['email']).toLowerCase(),
          'profilePic': _first(data, const ['profilePic', 'photoUrl']),
          'avatarColorIndex': _avatarColorIndex(userId),
          'paidToManager': 0.0,
          'joinedAt': FieldValue.serverTimestamp(),
        },
      );
      _touchEvent(batch, groupId, eventId);
      _touchProject(batch, groupId);
      await batch.commit();
    } on TourFailure {
      rethrow;
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
      final expenses = _eventCollection(groupId, eventId, 'expenses');
      final payments = _eventCollection(groupId, eventId, 'extraPayments');
      final results = await Future.wait([
        expenses.where('paidByMemberId', isEqualTo: userId).limit(1).get(),
        expenses
            .where('beneficiaryMemberIds', arrayContains: userId)
            .limit(1)
            .get(),
        payments.where('memberId', isEqualTo: userId).limit(1).get(),
      ]);
      if (results.any((snapshot) => snapshot.docs.isNotEmpty)) {
        throw const TourFailure('tour_error_member_has_records');
      }
      final batch = _firestore.batch();
      batch.delete(
        _eventCollection(groupId, eventId, 'participants').doc(userId),
      );
      _touchEvent(batch, groupId, eventId);
      _touchProject(batch, groupId);
      await batch.commit();
    } on TourFailure {
      rethrow;
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> updateParticipantPayment({
    required String groupId,
    required String eventId,
    required String userId,
    required double paidToManager,
  }) async {
    try {
      final batch = _firestore.batch();
      batch.update(
        _eventCollection(groupId, eventId, 'participants').doc(userId),
        {'paidToManager': paidToManager},
      );
      _touchEvent(batch, groupId, eventId);
      _touchProject(batch, groupId);
      await batch.commit();
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Stream<List<TourExpense>> watchExpenses({
    required String groupId,
    required String eventId,
  }) => _watchList(
    _eventCollection(groupId, eventId, 'expenses'),
    TourFirestoreMapper.expense,
    (items) => items..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
  );

  @override
  Future<void> createExpense({
    required String groupId,
    required String eventId,
    required String title,
    required double amount,
    required TourExpenseCategory category,
    required String? paidByMemberId,
    required bool paidByAllMembers,
    required List<String> beneficiaryMemberIds,
    required String createdBy,
    String? note,
  }) async {
    try {
      final expense = _eventCollection(groupId, eventId, 'expenses').doc();
      final batch = _firestore.batch();
      batch.set(expense, {
        'title': title.trim(),
        'amount': amount,
        'category': category.value,
        'paidByMemberId': paidByAllMembers ? null : paidByMemberId,
        'paidByAllMembers': paidByAllMembers,
        'beneficiaryMemberIds': beneficiaryMemberIds,
        'note': _nullable(note),
        'createdBy': createdBy,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _touchEvent(batch, groupId, eventId);
      _touchProject(batch, groupId);
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
      final batch = _firestore.batch();
      batch.delete(
        _eventCollection(groupId, eventId, 'expenses').doc(expenseId),
      );
      _touchEvent(batch, groupId, eventId);
      _touchProject(batch, groupId);
      await batch.commit();
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Stream<List<TourExtraPayment>> watchExtraPayments({
    required String groupId,
    required String eventId,
  }) => _watchList(
    _eventCollection(groupId, eventId, 'extraPayments'),
    TourFirestoreMapper.extraPayment,
    (items) => items..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
  );

  @override
  Future<void> createExtraPayment({
    required String groupId,
    required String eventId,
    required String memberId,
    required double amount,
    required String createdBy,
    String? note,
  }) async {
    try {
      final payment = _eventCollection(groupId, eventId, 'extraPayments').doc();
      final batch = _firestore.batch();
      batch.set(payment, {
        'memberId': memberId,
        'amount': amount,
        'note': _nullable(note),
        'createdBy': createdBy,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _touchEvent(batch, groupId, eventId);
      _touchProject(batch, groupId);
      await batch.commit();
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> deleteExtraPayment({
    required String groupId,
    required String eventId,
    required String paymentId,
  }) async {
    try {
      final batch = _firestore.batch();
      batch.delete(
        _eventCollection(groupId, eventId, 'extraPayments').doc(paymentId),
      );
      _touchEvent(batch, groupId, eventId);
      _touchProject(batch, groupId);
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

  Future<void> _createEventDocuments({
    required String groupId,
    required DocumentReference<Map<String, dynamic>> event,
    required String tourName,
    required double decidedBudget,
    required String createdBy,
    required double contribution,
    required List<DocumentSnapshot<Map<String, dynamic>>> members,
  }) async {
    const participantWritesPerBatch = 498;
    var start = 0;
    var isFirstBatch = true;
    while (start < members.length || isFirstBatch) {
      final batch = _firestore.batch();
      if (isFirstBatch) {
        batch.set(event, {
          'tourName': tourName.trim(),
          'decidedBudget': decidedBudget,
          'status': TourEventStatus.active.value,
          'createdBy': createdBy,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'completedAt': null,
        });
      } else {
        batch.update(event, {'updatedAt': FieldValue.serverTimestamp()});
      }
      _touchProject(batch, groupId);

      final end = (start + participantWritesPerBatch).clamp(0, members.length);
      for (final member in members.sublist(start, end)) {
        final data = member.data() ?? const <String, dynamic>{};
        batch.set(event.collection('participants').doc(member.id), {
          'id': member.id,
          'username': _first(data, const ['username', 'displayName']),
          'email': _first(data, const ['email']).toLowerCase(),
          'profilePic': _first(data, const ['profilePic', 'photoUrl']),
          'avatarColorIndex': _avatarColorIndex(member.id),
          'paidToManager': contribution,
          'joinedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      start = end;
      isFirstBatch = false;
    }
  }

  Future<void> _updateBudgetDocuments({
    required String groupId,
    required String eventId,
    required double decidedBudget,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> participants,
  }) async {
    const participantWritesPerBatch = 498;
    final contribution = TourCalculator.equalContribution(
      totalBudget: decidedBudget,
      participantCount: participants.length,
    );
    var start = 0;
    while (start < participants.length) {
      final batch = _firestore.batch();
      batch.update(_event(groupId, eventId), {
        'decidedBudget': decidedBudget,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _touchProject(batch, groupId);

      final end = (start + participantWritesPerBatch).clamp(
        0,
        participants.length,
      );
      for (final participant in participants.sublist(start, end)) {
        batch.update(participant.reference, {'paidToManager': contribution});
      }
      await batch.commit();
      start = end;
    }
  }

  void _touchEvent(WriteBatch batch, String groupId, String eventId) {
    batch.update(_event(groupId, eventId), {
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  void _touchProject(WriteBatch batch, String groupId) {
    batch.update(_project(groupId), {
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Map<String, Object> createProjectData({
    required String name,
    required String adminId,
    required Object createdAt,
    required Object updatedAt,
  }) => {
    'name': name.trim(),
    'adminId': adminId,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  static int _byCandidateName(
    TourParticipantCandidate a,
    TourParticipantCandidate b,
  ) => a.username.toLowerCase().compareTo(b.username.toLowerCase());

  static int _byParticipantName(TourParticipant a, TourParticipant b) =>
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

  int _avatarColorIndex(String id) =>
      id.codeUnits.fold<int>(0, (value, unit) => value + unit) % 8;

  TourFailure _failure(FirebaseException error) {
    final key = switch (error.code) {
      'permission-denied' => 'tour_error_permission',
      'unavailable' || 'deadline-exceeded' => 'tour_error_offline',
      _ => 'tour_error_firestore',
    };
    return TourFailure(key, error);
  }
}
