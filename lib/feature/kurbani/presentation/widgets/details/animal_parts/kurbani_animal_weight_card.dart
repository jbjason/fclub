import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:flutter/material.dart';

class KurbaniAnimalWeightCard extends StatelessWidget {
  const KurbaniAnimalWeightCard({
    super.key,
    required this.totalWeight,
    required this.partCount,
    required this.assignedCount,
  });

  final double totalWeight;
  final int partCount;
  final int assignedCount;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF422006), Color(0xFF9A3412), Color(0xFF4C1D95)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(19),
          ),
          child: const Icon(
            Icons.scale_rounded,
            color: KurbaniPalette.gold,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'kurbani_total_weight'.tr(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .65),
                  fontFamily: MyString.rubikMedium,
                  fontSize: 10,
                ),
              ),
              Text(
                'kurbani_weight_value'.tr(
                  namedArgs: {'weight': totalWeight.toStringAsFixed(1)},
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: MyString.poppinsBold,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'kurbani_parts_count'.tr(namedArgs: {'count': '$partCount'}),
              style: const TextStyle(
                color: KurbaniPalette.gold,
                fontFamily: MyString.rubikMedium,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'kurbani_assigned_count'.tr(
                namedArgs: {'count': '$assignedCount'},
              ),
              style: TextStyle(
                color: Colors.white.withValues(alpha: .58),
                fontFamily: MyString.rubikRegular,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
