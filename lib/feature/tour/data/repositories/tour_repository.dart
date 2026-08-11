import 'package:fclub/feature/tour/data/models/tour_event.dart';
import 'package:fclub/feature/tour/data/models/tour_expense.dart';
import 'package:fclub/feature/tour/data/models/tour_extra_payment.dart';
import 'package:fclub/feature/tour/data/models/tour_participant.dart';
import 'package:fclub/feature/tour/data/models/tour_project.dart';

abstract interface class TourRepository {
  Future<TourProject?> findProject({required String groupId});

  Future<String?> getGroupAdminId({required String groupId});

  Future<TourProject> createProject({
    required String groupId,
    required String name,
    required String adminId,
  });

  Stream<TourProject?> watchProject({required String groupId});

  Stream<List<TourEvent>> watchEvents({required String groupId});

  Stream<TourEvent?> watchEvent({
    required String groupId,
    required String eventId,
  });

  Future<List<TourParticipantCandidate>> getGroupMembers({
    required String groupId,
  });

  Future<TourEvent> createEvent({
    required String groupId,
    required String tourName,
    required double decidedBudget,
    required String createdBy,
    required List<String> participantIds,
  });

  Future<void> updateEventBudget({
    required String groupId,
    required String eventId,
    required double decidedBudget,
  });

  Future<void> updateEventStatus({
    required String groupId,
    required String eventId,
    required TourEventStatus status,
  });

  Future<void> deleteEvent({required String groupId, required String eventId});

  Stream<List<TourParticipant>> watchParticipants({
    required String groupId,
    required String eventId,
  });

  Future<List<TourParticipantCandidate>> getAvailableParticipants({
    required String groupId,
    required String eventId,
  });

  Future<void> addParticipant({
    required String groupId,
    required String eventId,
    required String userId,
  });

  Future<void> removeParticipant({
    required String groupId,
    required String eventId,
    required String userId,
  });

  Future<void> updateParticipantPayment({
    required String groupId,
    required String eventId,
    required String userId,
    required double paidToManager,
  });

  Stream<List<TourExpense>> watchExpenses({
    required String groupId,
    required String eventId,
  });

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
  });

  Future<void> deleteExpense({
    required String groupId,
    required String eventId,
    required String expenseId,
  });

  Stream<List<TourExtraPayment>> watchExtraPayments({
    required String groupId,
    required String eventId,
  });

  Future<void> createExtraPayment({
    required String groupId,
    required String eventId,
    required String memberId,
    required double amount,
    required String createdBy,
    String? note,
  });

  Future<void> deleteExtraPayment({
    required String groupId,
    required String eventId,
    required String paymentId,
  });
}
