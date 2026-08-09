import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fclub/feature/club/data/model/club_member_model.dart';
import 'package:fclub/feature/club/data/model/club_payment_model.dart';
import 'package:fclub/feature/club/data/model/club_failure.dart';
import 'package:fclub/feature/club/data/model/club_member.dart';
import 'package:fclub/feature/club/data/model/club_payment.dart';
import 'package:fclub/feature/club/data/model/club_payment_filter.dart';
import 'package:fclub/feature/club/data/model/club_project.dart';
import 'package:fclub/feature/club/data/model/club_project_model.dart';
import 'package:fclub/feature/club/data/repositories/club_repository.dart';

class FirestoreClubRepository implements ClubRepository {
  FirestoreClubRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String projectDocumentId = 'club';

  CollectionReference<Map<String, dynamic>> _projects(String groupId) {
    return _firestore.collection('groups').doc(groupId).collection('projects');
  }

  DocumentReference<Map<String, dynamic>> _project(
    String groupId,
    String projectId,
  ) {
    return _projects(groupId).doc(projectId);
  }

  CollectionReference<Map<String, dynamic>> _transactions(
    String groupId,
    String projectId,
  ) {
    return _project(groupId, projectId).collection('transactions');
  }

  CollectionReference<Map<String, dynamic>> _groupMembers(String groupId) {
    return _firestore.collection('groups').doc(groupId).collection('members');
  }

  CollectionReference<Map<String, dynamic>> _participants(
    String groupId,
    String projectId,
  ) {
    return _project(groupId, projectId).collection('participants');
  }

  @override
  Future<ClubProject?> findProject({required String groupId}) async {
    try {
      return ClubProjectModel.fromFirestore(
        await _project(groupId, projectDocumentId).get(),
      );
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<String?> getGroupAdminId({required String groupId}) async {
    try {
      final snapshot = await _firestore.collection('groups').doc(groupId).get();
      final value = snapshot.data()?['createdBy'];
      return value is String && value.trim().isNotEmpty ? value.trim() : null;
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<ClubProject> createProject({
    required String groupId,
    required String name,
    required String adminId,
    required double monthlyTargetPerMember,
  }) async {
    final member = _groupMembers(groupId).doc(adminId);
    final project = _projects(groupId).doc(projectDocumentId);
    final participant = project.collection('participants').doc(adminId);
    try {
      await _firestore.runTransaction((transaction) async {
        final existing = await transaction.get(project);
        if (existing.exists) {
          throw const ClubFailure('This group already has a Club project.');
        }
        final memberSnapshot = await transaction.get(member);
        final memberData = memberSnapshot.data();
        if (!memberSnapshot.exists || memberData == null) {
          throw const ClubFailure('Only a group member can create a Club.');
        }
        transaction.set(
          project,
          createProjectData(
            name: name,
            adminId: adminId,
            monthlyTargetPerMember: monthlyTargetPerMember,
            createdAt: FieldValue.serverTimestamp(),
          ),
        );
        transaction.set(participant, {
          'id': adminId,
          'username': _memberText(memberData, const [
            'username',
            'displayName',
          ]),
          'email': _normalizedEmail(memberData['email']),
          'profilePic': _memberText(memberData, const [
            'profilePic',
            'photoUrl',
          ]),
          'joinedAt': FieldValue.serverTimestamp(),
        });
      });
      return ClubProject(
        id: project.id,
        name: name.trim(),
        adminId: adminId,
        monthlyTargetPerMember: monthlyTargetPerMember,
      );
    } on ClubFailure {
      rethrow;
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Stream<List<ClubPayment>> watchPayments({
    required String groupId,
    required String projectId,
    ClubPaymentFilter filter = const ClubPaymentFilter(),
  }) async* {
    Query<Map<String, dynamic>> query = _transactions(
      groupId,
      projectId,
    ).where('type', isEqualTo: 'contribution');
    if (filter.userId != null) {
      query = query.where('userId', isEqualTo: filter.userId);
    }
    if (filter.month != null) {
      query = query.where('month', isEqualTo: filter.month);
    }
    if (filter.status != null) {
      query = query.where('status', isEqualTo: filter.status!.value);
    }
    if (filter.paymentMethod != null) {
      query = query.where(
        'paymentMethod',
        isEqualTo: filter.paymentMethod!.value,
      );
    }

    try {
      await for (final snapshot in query.snapshots()) {
        final payments = snapshot.docs
            .map(ClubPaymentModel.fromFirestore)
            .toList(growable: false);
        yield payments.toList()..sort(
          (first, second) => second.submittedAt.compareTo(first.submittedAt),
        );
      }
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Stream<List<ClubMember>> watchMembers({
    required String groupId,
    required String projectId,
  }) async* {
    try {
      await for (final snapshot in _participants(
        groupId,
        projectId,
      ).snapshots()) {
        final members = snapshot.docs
            .map(ClubMemberModel.fromFirestore)
            .toList(growable: false);
        yield members.toList()..sort(
          (first, second) =>
              first.name.toLowerCase().compareTo(second.name.toLowerCase()),
        );
      }
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Stream<String?> watchAdminId({
    required String groupId,
    required String projectId,
  }) async* {
    try {
      await for (final snapshot in _project(groupId, projectId).snapshots()) {
        final value = snapshot.data()?['adminId'];
        yield value is String && value.trim().isNotEmpty ? value.trim() : null;
      }
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<List<ClubMemberCandidate>> getAvailableMembers({
    required String groupId,
    required String projectId,
  }) async {
    try {
      final participantSnapshot = await _participants(groupId, projectId).get();
      final existingIds = participantSnapshot.docs
          .map((document) => document.id)
          .toSet();
      final existingEmails = participantSnapshot.docs
          .map((document) => _normalizedEmail(document.data()['email']))
          .where((email) => email.isNotEmpty)
          .toSet();
      final groupMembersSnapshot = await _groupMembers(groupId).get();
      final seenEmails = <String>{...existingEmails};
      final candidates = <ClubMemberCandidate>[];
      for (final document in groupMembersSnapshot.docs) {
        if (existingIds.contains(document.id)) continue;
        final candidate = ClubMemberModel.candidateFromFirestore(document);
        final email = _normalizedEmail(candidate.email);
        if (email.isNotEmpty && seenEmails.contains(email)) continue;
        if (email.isNotEmpty) seenEmails.add(email);
        candidates.add(candidate);
      }
      return candidates..sort(
        (first, second) =>
            first.name.toLowerCase().compareTo(second.name.toLowerCase()),
      );
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> createPayment({
    required String groupId,
    required String projectId,
    required String userId,
    required double amount,
    required String month,
    required PaymentStatus status,
    required PaymentMethod paymentMethod,
    required String submittedBy,
    String? note,
  }) async {
    try {
      final document = _transactions(groupId, projectId).doc();
      await document.set({
        'type': 'contribution',
        'userId': userId,
        'amount': amount,
        'month': month,
        'status': status.value,
        'paymentMethod': paymentMethod.value,
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
  Future<void> updatePaymentStatus({
    required String groupId,
    required String projectId,
    required String paymentId,
    required PaymentStatus status,
    required String reviewedBy,
  }) async {
    try {
      final review = status == PaymentStatus.pending
          ? <String, Object?>{
              'status': status.value,
              'reviewedBy': null,
              'reviewedAt': null,
            }
          : <String, Object?>{
              'status': status.value,
              'reviewedBy': reviewedBy,
              'reviewedAt': FieldValue.serverTimestamp(),
            };
      await _transactions(groupId, projectId).doc(paymentId).update(review);
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> addMember({
    required String groupId,
    required String projectId,
    required ClubMemberCandidate member,
  }) async {
    try {
      final groupMember = await _groupMembers(groupId).doc(member.id).get();
      final memberData = groupMember.data();
      if (!groupMember.exists || memberData == null) {
        throw const ClubFailure('Choose an existing group member.');
      }
      await _participants(groupId, projectId).doc(member.id).set({
        'id': member.id,
        'username': _memberText(memberData, const ['username', 'displayName']),
        'email': _normalizedEmail(memberData['email']),
        'profilePic': _memberText(memberData, const ['profilePic', 'photoUrl']),
        'joinedAt': FieldValue.serverTimestamp(),
      });
    } on ClubFailure {
      rethrow;
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> removeMember({
    required String groupId,
    required String projectId,
    required String memberId,
  }) async {
    try {
      await _participants(groupId, projectId).doc(memberId).delete();
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
    final newAdmin = _participants(groupId, projectId).doc(newAdminId);
    try {
      await _firestore.runTransaction((transaction) async {
        final projectSnapshot = await transaction.get(project);
        final newAdminSnapshot = await transaction.get(newAdmin);
        final storedAdminId = projectSnapshot.data()?['adminId'];
        if (storedAdminId != currentAdminId) {
          throw const ClubFailure(
            'Only the current Club admin can transfer administration.',
          );
        }
        if (!newAdminSnapshot.exists) {
          throw const ClubFailure('Choose an active Club member as admin.');
        }
        transaction.update(project, {
          'adminId': newAdminId,
          'adminUpdatedAt': FieldValue.serverTimestamp(),
        });
      });
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  static Map<String, Object> createMemberData({
    required ClubMemberCandidate member,
    required Object joinedAt,
  }) {
    return {
      'id': member.id,
      'username': member.name,
      'email': member.email.trim().toLowerCase(),
      'profilePic': member.profilePic,
      'joinedAt': joinedAt,
    };
  }

  static Map<String, Object> createProjectData({
    required String name,
    required String adminId,
    required double monthlyTargetPerMember,
    required Object createdAt,
  }) {
    return {
      'name': name.trim(),
      'adminId': adminId,
      'createdAt': createdAt,
      'monthlyTargetPerMember': monthlyTargetPerMember,
    };
  }

  Object? _cleanNote(String? note) {
    final value = note?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  String _normalizedEmail(Object? email) {
    return email is String ? email.trim().toLowerCase() : '';
  }

  String _memberText(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }

  ClubFailure _failure(FirebaseException error) {
    final message = switch (error.code) {
      'permission-denied' => 'You do not have permission for this action.',
      'unavailable' || 'deadline-exceeded' =>
        'Could not reach Firestore. Check your connection and try again.',
      _ => 'The Club data could not be updated. Please try again.',
    };
    return ClubFailure(message, error);
  }
}
