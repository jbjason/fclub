import 'package:fclub/feature/kurbani/data/models/kurbani_member_balance.dart';

class KurbaniSummary {
  const KurbaniSummary({
    required this.totalPlanned,
    required this.totalCollected,
    required this.totalSpent,
    required this.memberBalances,
  });

  final double totalPlanned;
  final double totalCollected;
  final double totalSpent;
  final List<KurbaniMemberBalance> memberBalances;

  double get balance => totalCollected - totalSpent;
  bool get isDeficit => balance < -.01;
  bool get isSurplus => balance > .01;
  double get collectionProgress =>
      totalPlanned <= 0 ? 0 : (totalCollected / totalPlanned).clamp(0.0, 1.0);
}
