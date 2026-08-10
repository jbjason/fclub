import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_summary.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:flutter/material.dart';

class KurbaniSettlementOverview extends StatelessWidget {
  const KurbaniSettlementOverview({super.key, required this.summary});

  final KurbaniSummary summary;

  @override
  Widget build(BuildContext context) {
    final accent = summary.isDeficit
        ? KurbaniPalette.rose
        : KurbaniPalette.emerald;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [KurbaniPalette.midnight, accent.withValues(alpha: .78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              summary.isDeficit
                  ? Icons.south_east_rounded
                  : Icons.north_east_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.isDeficit
                      ? 'kurbani_pool_deficit'.tr()
                      : 'kurbani_pool_surplus'.tr(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .68),
                    fontFamily: MyString.rubikMedium,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  CurrencyFormatter.format(summary.balance.abs()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: MyString.poppinsBold,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'kurbani_settlement_explainer'.tr(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .58),
                    fontFamily: MyString.rubikRegular,
                    fontSize: 8.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
