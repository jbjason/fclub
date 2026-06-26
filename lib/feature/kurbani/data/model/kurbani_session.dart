import 'package:fclub/feature/kurbani/data/model/kurbani_animal_part_model.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_expense_model.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_member_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'kurbani_session.g.dart';

/// One annual Kurbani event.
///
/// Stores all members, expenses, and animal-part records for that year in a
/// self-contained record so past events remain fully browsable.
@HiveType(typeId: 24)
class KurbaniSession {
  KurbaniSession({
    required this.id,
    required this.groupName,
    required this.budgetPerMember,
    required this.createdAt,
    required this.members,
    required this.expenses,
    required this.animalParts,
    this.isCompleted = false,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  String groupName;

  @HiveField(2)
  double budgetPerMember;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  bool isCompleted;

  /// Participants for this session — embedded copies (not live box entries).
  @HiveField(5)
  List<KurbaniMemberModel> members;

  @HiveField(6)
  List<KurbaniExpenseModel> expenses;

  @HiveField(7)
  List<KurbaniAnimalPartModel> animalParts;

  // ── Computed helpers ──────────────────────────────────────────────────────

  double get totalSpent =>
      expenses.fold<double>(0, (s, e) => s + e.amount);

  double get totalBudget => budgetPerMember * members.length;
}
