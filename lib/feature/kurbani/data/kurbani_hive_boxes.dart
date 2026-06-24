import 'package:fclub/feature/kurbani/data/model/kurbani_animal_part_model.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_expense_model.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_member_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class KurbaniHiveBoxes {
  static const String membersBox = 'kurbani_members';
  static const String expensesBox = 'kurbani_expenses';
  static const String animalPartsBox = 'kurbani_animal_parts';
  static const String metaBox = 'kurbani_meta';

  static Future<void> openBoxes() async {
    if (!Hive.isAdapterRegistered(20)) {
      Hive.registerAdapter(KurbaniMemberModelAdapter());
    }
    if (!Hive.isAdapterRegistered(21)) {
      Hive.registerAdapter(KurbaniExpenseModelAdapter());
    }
    if (!Hive.isAdapterRegistered(22)) {
      Hive.registerAdapter(KurbaniAnimalPartModelAdapter());
    }

    await Future.wait([
      Hive.openBox<KurbaniMemberModel>(membersBox),
      Hive.openBox<KurbaniExpenseModel>(expensesBox),
      Hive.openBox<KurbaniAnimalPartModel>(animalPartsBox),
      Hive.openBox<dynamic>(metaBox),
    ]);
  }
}
