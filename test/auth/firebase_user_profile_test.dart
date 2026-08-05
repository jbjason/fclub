import 'package:fclub/feature/auth/data/model/firebase_user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializes a new user with empty group and image fields', () {
    const profile = FirebaseUserProfile(
      id: 'firebase-uid',
      email: 'member@example.com',
      name: 'Club Member',
    );

    expect(profile.toFirestore(), {
      'email': 'member@example.com',
      'groupId': '',
      'id': 'firebase-uid',
      'image': '',
      'name': 'Club Member',
    });
  });
}
