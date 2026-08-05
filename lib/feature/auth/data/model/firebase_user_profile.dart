class FirebaseUserProfile {
  const FirebaseUserProfile({
    required this.id,
    required this.email,
    required this.name,
  });

  final String id;
  final String email;
  final String name;

  Map<String, dynamic> toFirestore() {
    return {'email': email, 'groupId': '', 'id': id, 'image': '', 'name': name};
  }
}
