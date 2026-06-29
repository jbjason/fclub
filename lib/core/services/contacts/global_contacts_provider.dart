import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fclub/core/services/contacts/app_contact.dart';
import 'package:fclub/core/services/contacts/global_contacts_hive_box.dart';
import 'package:fclub/core/services/global_service.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Shared "choose member" pool used by Tour, Kurbani, and Club — backed by
/// the real `users` collection in Firestore, cached locally in Hive so the
/// last-known list is still available offline.
class GlobalContactsProvider with ChangeNotifier {
  GlobalContactsProvider()
    : _contactsBox = Hive.box<AppContact>(GlobalContactsHiveBox.boxName);

  final Box<AppContact> _contactsBox;

  List<AppContact> get contacts => _contactsBox.values.toList();

  bool get hasContacts => _contactsBox.isNotEmpty;

  AppContact? contactById(String id) => _contactsBox.get(id);

  AppContact? get meContact =>
      _contactsBox.values.where((c) => c.isMe).firstOrNull;

  /// Fetches every user from the Firestore `users` collection and replaces
  /// the local cache. The signed-in user's email is matched against each
  /// doc's `email` field to flag the corresponding contact as "me". On
  /// failure, the previously cached contacts are left untouched so the app
  /// still works offline.
  Future<void> loadContacts() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      final myEmail =
          GlobalService.instance.currentUser?.email?.trim().toLowerCase();

      final fetched = <AppContact>[];
      for (var i = 0; i < snapshot.docs.length; i++) {
        final data = snapshot.docs[i].data();
        final name = (data['name'] as String?)?.trim();
        final email = (data['email'] as String?)?.trim().toLowerCase();
        fetched.add(AppContact(
          id: snapshot.docs[i].id,
          name: name?.isNotEmpty == true ? name! : 'Unknown',
          avatarColorIndex: i,
          isMe: myEmail != null && email != null && email == myEmail,
        ));
      }

      await _contactsBox.clear();
      for (final contact in fetched) {
        await _contactsBox.put(contact.id, contact);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('GlobalContactsProvider.loadContacts failed: $e');
    }
  }
}
