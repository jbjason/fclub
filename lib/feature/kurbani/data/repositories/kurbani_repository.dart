import 'package:fclub/feature/kurbani/data/models/kurbani_animal_part.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_event.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_expense.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_participant.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_project.dart';

abstract interface class KurbaniRepository {
  Future<KurbaniProject?> findProject({required String groupId});

  Future<String?> getGroupAdminId({required String groupId});

  Future<KurbaniProject> createProject({
    required String groupId,
    required String name,
    required String adminId,
  });

  Stream<KurbaniProject?> watchProject({required String groupId});

  Stream<List<KurbaniEvent>> watchEvents({required String groupId});

  Stream<KurbaniEvent?> watchEvent({
    required String groupId,
    required String eventId,
  });

  Future<List<KurbaniParticipant>> getGroupMembers({required String groupId});

  Future<KurbaniEvent> createEvent({
    required String groupId,
    required String name,
    required List<String> participantIds,
    required double contribution,
  });

  Future<void> updateEventStatus({
    required String groupId,
    required String eventId,
    required KurbaniEventStatus status,
  });

  Future<void> deleteEvent({required String groupId, required String eventId});

  Stream<List<KurbaniParticipant>> watchParticipants({
    required String groupId,
    required String eventId,
  });

  Future<List<KurbaniParticipant>> getAvailableParticipants({
    required String groupId,
    required String eventId,
  });

  Future<void> addParticipant({
    required String groupId,
    required String eventId,
    required String userId,
    required double contribution,
  });

  Future<void> updateParticipant({
    required String groupId,
    required String eventId,
    required String userId,
    required double contribution,
    required KurbaniPaidStatus paidStatus,
  });

  Future<void> removeParticipant({
    required String groupId,
    required String eventId,
    required String userId,
  });

  Stream<List<KurbaniExpense>> watchExpenses({
    required String groupId,
    required String eventId,
  });

  Future<void> createExpense({
    required String groupId,
    required String eventId,
    required String title,
    required double amount,
    required String? paidByMemberId,
    required bool paidByAllMembers,
    required String createdBy,
    String? note,
  });

  Future<void> deleteExpense({
    required String groupId,
    required String eventId,
    required String expenseId,
  });

  Stream<List<KurbaniAnimalPart>> watchAnimalParts({
    required String groupId,
    required String eventId,
  });

  Future<void> createAnimalPart({
    required String groupId,
    required String eventId,
    required String name,
    required double weightKg,
    required String createdBy,
    String? assignedToUid,
    String? note,
  });

  Future<void> deleteAnimalPart({
    required String groupId,
    required String eventId,
    required String partId,
  });
}
