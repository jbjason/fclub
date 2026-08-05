import 'package:fclub/feature/club/data/model/club_member.dart';
import 'package:fclub/feature/club/data/model/club_payment.dart';
import 'package:fclub/feature/club/data/model/club_payment_filter.dart';

abstract interface class ClubRepository {
  Stream<List<ClubPayment>> watchPayments({
    required String groupId,
    required String projectId,
    ClubPaymentFilter filter = const ClubPaymentFilter(),
  });

  Stream<List<ClubMember>> watchMembers({required String groupId});

  Future<List<ClubMemberCandidate>> getAvailableMembers({
    required String groupId,
  });

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
  });

  Future<void> updatePaymentStatus({
    required String groupId,
    required String projectId,
    required String paymentId,
    required PaymentStatus status,
    required String reviewedBy,
  });

  Future<void> deletePayment({
    required String groupId,
    required String projectId,
    required String paymentId,
  });

  Future<void> addMember({
    required String groupId,
    required ClubMemberCandidate member,
  });

  Future<void> removeMember({
    required String groupId,
    required String memberId,
  });
}
