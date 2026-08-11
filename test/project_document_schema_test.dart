import 'package:fclub/feature/club/data/repositories/firestore_club_repository.dart';
import 'package:fclub/feature/locker/data/repositories/firestore_locker_repository.dart';
import 'package:fclub/feature/kurbani/data/repositories/firestore_kurbani_repository.dart';
import 'package:fclub/feature/tour/data/repositories/firestore_tour_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Club uses its type as the deterministic project document ID', () {
    expect(FirestoreClubRepository.projectDocumentId, 'club');

    final data = FirestoreClubRepository.createProjectData(
      name: '  Monthly Circle  ',
      adminId: 'admin-id',
      monthlyTargetPerMember: 5000,
      createdAt: DateTime(2026, 8, 10),
    );

    expect(data['name'], 'Monthly Circle');
    expect(data, isNot(contains('type')));
  });

  test('Locker uses its type as the deterministic project document ID', () {
    expect(FirestoreLockerRepository.projectDocumentId, 'locker');

    final data = FirestoreLockerRepository.createProjectData(
      name: '  Shared Treasury  ',
      adminId: 'admin-id',
      createdAt: DateTime(2026, 8, 10),
    );

    expect(data['name'], 'Shared Treasury');
    expect(data, isNot(contains('type')));
  });

  test('Kurbani uses its type as the deterministic project document ID', () {
    expect(FirestoreKurbaniRepository.projectDocumentId, 'kurbani');

    final data = FirestoreKurbaniRepository.createProjectData(
      name: '  Eid Circle  ',
      adminId: 'admin-id',
      createdAt: DateTime(2026, 8, 10),
    );

    expect(data['name'], 'Eid Circle');
    expect(data['status'], 'active');
    expect(data, isNot(contains('type')));
  });

  test('Tour uses its type as the deterministic project document ID', () {
    expect(FirestoreTourRepository.projectDocumentId, 'tour');

    final data = FirestoreTourRepository.createProjectData(
      name: '  Group Adventures  ',
      adminId: 'admin-id',
      createdAt: DateTime(2026, 8, 11),
      updatedAt: DateTime(2026, 8, 11),
    );

    expect(data['name'], 'Group Adventures');
    expect(data['adminId'], 'admin-id');
    expect(data, isNot(contains('type')));
  });
}
