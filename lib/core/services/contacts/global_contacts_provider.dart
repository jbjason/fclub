import 'package:fclub/core/services/contacts/app_contact.dart';
import 'package:fclub/core/services/contacts/global_contacts_hive_box.dart';
import 'package:fclub/core/services/global_service.dart';
import 'package:fclub/feature/auth/data/model/auth_user.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Shared "choose member" pool used by both the Tour and Kurbani features.
class GlobalContactsProvider with ChangeNotifier {
  GlobalContactsProvider()
    : _contactsBox = Hive.box<AppContact>(GlobalContactsHiveBox.boxName);

  final Box<AppContact> _contactsBox;

  List<AppContact> get contacts => _contactsBox.values.toList();

  AppContact? get meContact =>
      _contactsBox.values.where((c) => c.isMe).firstOrNull;

  bool get hasDemoData => _contactsBox.isNotEmpty;

  AppContact? contactById(String id) => _contactsBox.get(id);

  Future<void> seedDemoData() async {
    if (hasDemoData) return;

    final youName = _resolveDisplayName(GlobalService.instance.currentUser);

    final list = [
      AppContact(id: 'me', name: youName, avatarColorIndex: 0, isMe: true),
      AppContact(id: 'c1', name: 'Belaak Noyon', avatarColorIndex: 1),
      AppContact(id: 'c2', name: 'Bolod Alamin', avatarColorIndex: 2),
      AppContact(id: 'c3', name: 'Rasel Paada', avatarColorIndex: 3),
      AppContact(id: 'c4', name: 'Taaut Rumi', avatarColorIndex: 4),
      AppContact(id: 'c5', name: 'Sesra Joynal', avatarColorIndex: 5),
      AppContact(id: 'c6', name: 'Gaanja Monir', avatarColorIndex: 6),
      AppContact(id: 'c7', name: 'Tank Nazmul', avatarColorIndex: 0),
      AppContact(id: 'c8', name: 'Baatu Miraj', avatarColorIndex: 1),
      AppContact(id: 'c9', name: 'Kaatbaaj Ashraful', avatarColorIndex: 2),
      AppContact(id: 'c10', name: 'Demo User1', avatarColorIndex: 3),
      AppContact(id: 'c11', name: 'Demo User2', avatarColorIndex: 4),
    ];

    for (final contact in list) {
      await _contactsBox.put(contact.id, contact);
    }
    notifyListeners();
  }

  String _resolveDisplayName(AuthUser? user) {
    if (user == null) return 'You';
    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;
    final email = user.email;
    if (email != null && email.contains('@')) return email.split('@').first;
    return 'You';
  }
}
