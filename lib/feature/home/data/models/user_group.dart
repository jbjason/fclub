class UserGroup {
  const UserGroup({required this.id, required this.name, required this.role});

  final String id;
  final String name;
  final String role;

  bool get isAdmin => role.toLowerCase() == 'admin';
}
