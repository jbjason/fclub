import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fclub/feature/club/data/model/club_member_model.dart';
import 'package:fclub/feature/club/data/model/club_payment_model.dart';
import 'package:fclub/feature/club/data/model/club_constants.dart';
import 'package:fclub/feature/club/data/model/club_failure.dart';
import 'package:fclub/feature/club/data/model/club_member.dart';
import 'package:fclub/feature/club/data/model/club_payment.dart';
import 'package:fclub/feature/club/data/model/club_payment_filter.dart';
import 'package:fclub/feature/club/data/repositories/club_repository.dart';

class FirestoreClubRepository implements ClubRepository {
  FirestoreClubRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String clubProjectId = ClubConstants.projectId;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _payments(
    String groupId,
    String projectId,
  ) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('projects')
        .doc(projectId)
        .collection('payments');
  }

  CollectionReference<Map<String, dynamic>> _members(String groupId) {
    return _firestore.collection('groups').doc(groupId).collection('members');
  }

  @override
  Stream<List<ClubPayment>> watchPayments({
    required String groupId,
    required String projectId,
    ClubPaymentFilter filter = const ClubPaymentFilter(),
  }) async* {
    Query<Map<String, dynamic>> query = _payments(groupId, projectId);
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
  Stream<List<ClubMember>> watchMembers({required String groupId}) async* {
    try {
      await for (final snapshot in _members(groupId).snapshots()) {
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
  Future<List<ClubMemberCandidate>> getAvailableMembers({
    required String groupId,
  }) async {
    try {
      final memberSnapshot = await _members(groupId).get();
      final existingIds = memberSnapshot.docs
          .map((document) => document.id)
          .toSet();
      final existingEmails = memberSnapshot.docs
          .map((document) => _normalizedEmail(document.data()['email']))
          .where((email) => email.isNotEmpty)
          .toSet();
      final usersSnapshot = await _firestore.collection('users').get();
      final seenEmails = <String>{...existingEmails};
      final candidates = <ClubMemberCandidate>[];
      for (final document in usersSnapshot.docs) {
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
      final document = _payments(groupId, projectId).doc();
      await document.set({
        'id': document.id,
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
      await _payments(groupId, projectId).doc(paymentId).update(review);
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> deletePayment({
    required String groupId,
    required String projectId,
    required String paymentId,
  }) async {
    try {
      await _payments(groupId, projectId).doc(paymentId).delete();
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> addMember({
    required String groupId,
    required ClubMemberCandidate member,
  }) async {
    try {
      await _members(groupId).doc(member.id).set({
        'id': member.id,
        'username': member.name,
        'email': member.email.trim().toLowerCase(),
        'profilePic': member.profilePic,
        'role': 'member',
        'joinedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> removeMember({
    required String groupId,
    required String memberId,
  }) async {
    try {
      await _members(groupId).doc(memberId).delete();
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  Object? _cleanNote(String? note) {
    final value = note?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  String _normalizedEmail(Object? email) {
    return email is String ? email.trim().toLowerCase() : '';
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
