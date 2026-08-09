import 'package:fclub/feature/locker/data/models/locker_participant.dart';
import 'package:fclub/feature/locker/data/models/locker_project.dart';
import 'package:fclub/feature/locker/data/models/locker_transaction.dart';

abstract interface class LockerRepository {
  Future<LockerProject?> findProject({required String groupId});

  Future<String?> getGroupAdminId({required String groupId});

  Future<LockerProject> createProject({
    required String groupId,
    required String name,
    required String adminId,
  });

  Stream<LockerProject?> watchProject({
    required String groupId,
    required String projectId,
  });

  Stream<List<LockerParticipant>> watchParticipants({
    required String groupId,
    required String projectId,
  });

  Stream<List<LockerTransaction>> watchTransactions({
    required String groupId,
    required String projectId,
    String? userId,
  });

  Future<List<LockerParticipant>> getAvailableParticipants({
    required String groupId,
    required String projectId,
  });

  Future<void> addParticipant({
    required String groupId,
    required String projectId,
    required String userId,
  });

  Future<void> removeParticipant({
    required String groupId,
    required String projectId,
    required String userId,
  });

  Future<void> transferAdmin({
    required String groupId,
    required String projectId,
    required String currentAdminId,
    required String newAdminId,
  });

  Future<void> createTransaction({
    required String groupId,
    required String projectId,
    required LockerTransactionType type,
    required double amount,
    required String userId,
    required LockerTransactionStatus status,
    required String submittedBy,
    String? note,
  });

  Future<void> reviewTransaction({
    required String groupId,
    required String projectId,
    required String transactionId,
    required LockerTransactionStatus status,
    required String reviewedBy,
  });
}
