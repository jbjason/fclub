import 'package:cloud_firestore/cloud_firestore.dart';

class GroupUser {
  const GroupUser({
    required this.id,
    required this.username,
    required this.profilePic,
    required this.email,
  });

  final String id;
  final String username;
  final String profilePic;
  final String email;

  factory GroupUser.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    return GroupUser(
      id: document.id,
      username: _firstNonEmpty(data, const [
        'username',
        'name',
        'displayName',
      ], fallback: 'Fundora Member'),
      profilePic: _firstNonEmpty(data, const [
        'profilePic',
        'photoUrl',
        'photoURL',
      ]),
      email: _firstNonEmpty(data, const ['email']),
    );
  }

  GroupUser copyWith({
    String? id,
    String? username,
    String? profilePic,
    String? email,
  }) {
    return GroupUser(
      id: id ?? this.id,
      username: username ?? this.username,
      profilePic: profilePic ?? this.profilePic,
      email: email ?? this.email,
    );
  }

  static String _firstNonEmpty(
    Map<String, dynamic> data,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return fallback;
  }
}
