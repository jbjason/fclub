import 'package:fclub/feature/auth/data/model/firebase_user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializes a new user without legacy groupId', () {
    const profile = FirebaseUserProfile(
      id: 'firebase-uid',
      email: 'member@example.com',
      name: 'Club Member',
    );

    expect(profile.toFirestore(), {
      'email': 'member@example.com',
      'id': 'firebase-uid',
      'image': '',
      'name': 'Club Member',
    });
    expect(profile.toFirestore(), isNot(contains('groupId')));
  });
}
