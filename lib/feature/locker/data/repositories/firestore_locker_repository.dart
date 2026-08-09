import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fclub/feature/locker/data/models/locker_firestore_mapper.dart';
import 'package:fclub/feature/locker/data/models/locker_failure.dart';
import 'package:fclub/feature/locker/data/models/locker_participant.dart';
import 'package:fclub/feature/locker/data/models/locker_project.dart';
import 'package:fclub/feature/locker/data/models/locker_transaction.dart';
import 'package:fclub/feature/locker/data/repositories/locker_repository.dart';

class FirestoreLockerRepository implements LockerRepository {
  FirestoreLockerRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String projectDocumentId = 'locker';

  DocumentReference<Map<String, dynamic>> _group(String groupId) =>
      _firestore.collection('groups').doc(groupId);

  CollectionReference<Map<String, dynamic>> _projects(String groupId) =>
      _group(groupId).collection('projects');

  DocumentReference<Map<String, dynamic>> _project(
    String groupId,
    String projectId,
  ) => _projects(groupId).doc(projectId);

  CollectionReference<Map<String, dynamic>> _participants(
    String groupId,
    String projectId,
  ) => _project(groupId, projectId).collection('participants');

  CollectionReference<Map<String, dynamic>> _transactions(
    String groupId,
    String projectId,
  ) => _project(groupId, projectId).collection('transactions');

  @override
  Future<LockerProject?> findProject({required String groupId}) async {
    try {
      return LockerFirestoreMapper.project(
        await _project(groupId, projectDocumentId).get(),
      );
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<String?> getGroupAdminId({required String groupId}) async {
    try {
      final snapshot = await _group(groupId).get();
      final value = snapshot.data()?['createdBy'];
      return value is String && value.trim().isNotEmpty ? value.trim() : null;
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<LockerProject> createProject({
    required String groupId,
    required String name,
    required String adminId,
  }) async {
    final member = _group(groupId).collection('members').doc(adminId);
    final project = _projects(groupId).doc(projectDocumentId);
    final participant = project.collection('participants').doc(adminId);
    try {
      await _firestore.runTransaction((transaction) async {
        final existing = await transaction.get(project);
        if (existing.exists) {
          throw const LockerFailure('This group already has a Locker project.');
        }
        final memberSnapshot = await transaction.get(member);
        final memberData = memberSnapshot.data();
        if (!memberSnapshot.exists || memberData == null) {
          throw const LockerFailure('Only a group member can create a Locker.');
        }
        transaction.set(
          project,
          createProjectData(
            name: name,
            adminId: adminId,
            createdAt: FieldValue.serverTimestamp(),
          ),
        );
        transaction.set(participant, {
          'id': adminId,
          'username': _text(memberData, const ['username', 'displayName']),
          'email': _text(memberData, const ['email']).toLowerCase(),
          'profilePic': _text(memberData, const ['profilePic', 'photoUrl']),
          'joinedAt': FieldValue.serverTimestamp(),
        });
      });
      return LockerProject(id: project.id, name: name.trim(), adminId: adminId);
    } on LockerFailure {
      rethrow;
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Stream<LockerProject?> watchProject({
    required String groupId,
    required String projectId,
  }) async* {
    try {
      await for (final snapshot in _project(groupId, projectId).snapshots()) {
        yield LockerFirestoreMapper.project(snapshot);
      }
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Stream<List<LockerParticipant>> watchParticipants({
    required String groupId,
    required String projectId,
  }) async* {
    try {
      await for (final snapshot in _participants(
        groupId,
        projectId,
      ).snapshots()) {
        final participants = snapshot.docs
            .map(LockerFirestoreMapper.participant)
            .toList(growable: false);
        yield participants.toList()..sort(
          (a, b) =>
              a.username.toLowerCase().compareTo(b.username.toLowerCase()),
        );
      }
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Stream<List<LockerTransaction>> watchTransactions({
    required String groupId,
    required String projectId,
    String? userId,
  }) async* {
    Query<Map<String, dynamic>> query = _transactions(groupId, projectId);
    if (userId != null && userId.isNotEmpty) {
      query = query.where('userId', isEqualTo: userId);
    }
    try {
      await for (final snapshot in query.snapshots()) {
        final transactions = snapshot.docs
            .map(LockerFirestoreMapper.transaction)
            .toList(growable: false);
        yield transactions.toList()
          ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      }
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<List<LockerParticipant>> getAvailableParticipants({
    required String groupId,
    required String projectId,
  }) async {
    try {
      final participants = await _participants(groupId, projectId).get();
      final participantIds = participants.docs.map((doc) => doc.id).toSet();
      final members = await _group(groupId).collection('members').get();
      final candidates = members.docs
          .where((doc) => !participantIds.contains(doc.id))
          .map(LockerFirestoreMapper.participant)
          .toList(growable: false);
      return candidates..sort(
        (a, b) => a.username.toLowerCase().compareTo(b.username.toLowerCase()),
      );
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> addParticipant({
    required String groupId,
    required String projectId,
    required String userId,
  }) async {
    try {
      final member = await _group(
        groupId,
      ).collection('members').doc(userId).get();
      final data = member.data();
      if (!member.exists || data == null) {
        throw const LockerFailure('Choose an existing group member.');
      }
      await _participants(groupId, projectId).doc(userId).set({
        'id': userId,
        'username': _text(data, const ['username', 'displayName']),
        'email': _text(data, const ['email']).toLowerCase(),
        'profilePic': _text(data, const ['profilePic', 'photoUrl']),
        'joinedAt': FieldValue.serverTimestamp(),
      });
    } on LockerFailure {
      rethrow;
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> removeParticipant({
    required String groupId,
    required String projectId,
    required String userId,
  }) async {
    try {
      await _participants(groupId, projectId).doc(userId).delete();
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> transferAdmin({
    required String groupId,
    required String projectId,
    required String currentAdminId,
    required String newAdminId,
  }) async {
    final project = _project(groupId, projectId);
    final participant = _participants(groupId, projectId).doc(newAdminId);
    try {
      await _firestore.runTransaction((transaction) async {
        final projectSnapshot = await transaction.get(project);
        final participantSnapshot = await transaction.get(participant);
        if (projectSnapshot.data()?['adminId'] != currentAdminId) {
          throw const LockerFailure(
            'Only the current project admin can transfer administration.',
          );
        }
        if (!participantSnapshot.exists) {
          throw const LockerFailure('Choose an active participant as admin.');
        }
        transaction.update(project, {'adminId': newAdminId});
      });
    } on LockerFailure {
      rethrow;
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> createTransaction({
    required String groupId,
    required String projectId,
    required LockerTransactionType type,
    required double amount,
    required String userId,
    required LockerTransactionStatus status,
    required String submittedBy,
    String? note,
  }) async {
    try {
      await _transactions(groupId, projectId).add({
        'type': type.value,
        'amount': amount,
        'userId': userId,
        'status': status.value,
        'submittedBy': submittedBy,
        'submittedAt': FieldValue.serverTimestamp(),
        'reviewedBy': null,
        'reviewedAt': null,
        'note': _cleanNote(note),
      });
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> reviewTransaction({
    required String groupId,
    required String projectId,
    required String transactionId,
    required LockerTransactionStatus status,
    required String reviewedBy,
  }) async {
    if (status == LockerTransactionStatus.pending) {
      throw const LockerFailure('Choose approved or rejected.');
    }
    try {
      await _transactions(groupId, projectId).doc(transactionId).update({
        'status': status.value,
        'reviewedBy': reviewedBy,
        'reviewedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  String _text(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }

  Object? _cleanNote(String? note) {
    final value = note?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  static Map<String, Object> createProjectData({
    required String name,
    required String adminId,
    required Object createdAt,
  }) {
    return {'name': name.trim(), 'adminId': adminId, 'createdAt': createdAt};
  }

  LockerFailure _failure(FirebaseException error) {
    final message = switch (error.code) {
      'permission-denied' => 'You do not have permission for this action.',
      'unavailable' || 'deadline-exceeded' =>
        'Could not reach Firestore. Check your connection and try again.',
      _ => 'The Locker data could not be updated. Please try again.',
    };
    return LockerFailure(message, error);
  }
}
