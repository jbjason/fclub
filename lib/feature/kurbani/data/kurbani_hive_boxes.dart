import 'package:fclub/feature/kurbani/data/model/kurbani_animal_part_model.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_expense_model.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_global_contact.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_member_model.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_session.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class KurbaniHiveBoxes {
  // ── Session-based storage (current) ───────────────────────────────────────
  static const String sessionsBox = 'kurbani_sessions';
  static const String contactsBox = 'kurbani_contacts';

  static Future<void> openBoxes() async {
    // Embedded-type adapters (used by KurbaniSession internally)
    if (!Hive.isAdapterRegistered(20)) {
      Hive.registerAdapter(KurbaniMemberModelAdapter());
    }
    if (!Hive.isAdapterRegistered(21)) {
      Hive.registerAdapter(KurbaniExpenseModelAdapter());
    }
    if (!Hive.isAdapterRegistered(22)) {
      Hive.registerAdapter(KurbaniAnimalPartModelAdapter());
    }
    if (!Hive.isAdapterRegistered(23)) {
      Hive.registerAdapter(KurbaniGlobalContactAdapter());
    }
    if (!Hive.isAdapterRegistered(24)) {
      Hive.registerAdapter(KurbaniSessionAdapter());
    }

    await Future.wait([
      Hive.openBox<KurbaniSession>(sessionsBox),
      Hive.openBox<KurbaniGlobalContact>(contactsBox),
    ]);
  }
}
