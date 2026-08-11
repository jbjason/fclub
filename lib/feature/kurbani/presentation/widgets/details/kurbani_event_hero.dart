import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_event.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_summary.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_status_badge.dart';
import 'package:flutter/material.dart';

class KurbaniEventHero extends StatelessWidget {
  const KurbaniEventHero({
    super.key,
    required this.event,
    required this.summary,
    required this.participantCount,
  });

  final KurbaniEvent event;
  final KurbaniSummary summary;
  final int participantCount;

  @override
  Widget build(BuildContext context) {
    final balanceColor = summary.isDeficit
        ? KurbaniPalette.rose
        : KurbaniPalette.emerald;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: KurbaniPalette.heroGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: KurbaniPalette.violet.withValues(alpha: .2),
            blurRadius: 30,
            spreadRadius: -9,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'kurbani_event_dashboard'.tr(),
                      style: const TextStyle(
                        color: KurbaniPalette.gold,
                        fontFamily: MyString.rubikMedium,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: MyString.poppinsBold,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              KurbaniStatusBadge(status: event.status),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  label: 'kurbani_collected'.tr(),
                  value: CurrencyFormatter.format(summary.totalCollected),
                  color: KurbaniPalette.cyan,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeroMetric(
                  label: 'spent'.tr(),
                  value: CurrencyFormatter.format(summary.totalSpent),
                  color: KurbaniPalette.gold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeroMetric(
                  label: summary.isDeficit ? 'deficit'.tr() : 'surplus'.tr(),
                  value: CurrencyFormatter.format(summary.balance.abs()),
                  color: balanceColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: summary.collectionProgress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: .1),
              valueColor: const AlwaysStoppedAnimation(KurbaniPalette.emerald),
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Text(
                'kurbani_collection_progress'.tr(
                  namedArgs: {
                    'percent': '${(summary.collectionProgress * 100).round()}',
                  },
                ),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .62),
                  fontFamily: MyString.rubikRegular,
                  fontSize: 9,
                ),
              ),
              const Spacer(),
              Text(
                'kurbani_participant_count'.tr(
                  namedArgs: {'count': '$participantCount'},
                ),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .62),
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
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: color.withValues(alpha: .2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: .58),
            fontFamily: MyString.rubikRegular,
            fontSize: 8,
          ),
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontFamily: MyString.poppinsBold,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}
