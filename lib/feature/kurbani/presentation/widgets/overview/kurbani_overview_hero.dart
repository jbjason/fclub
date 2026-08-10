import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_event.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:flutter/material.dart';

class KurbaniOverviewHero extends StatelessWidget {
  const KurbaniOverviewHero({
    super.key,
    required this.projectName,
    required this.activeEvent,
    required this.completedCount,
  });

  final String projectName;
  final KurbaniEvent? activeEvent;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: KurbaniPalette.heroGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: KurbaniPalette.emerald.withValues(alpha: .22),
            blurRadius: 34,
            spreadRadius: -9,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -26,
            top: -30,
            child: Icon(
              Icons.nightlight_round,
              size: 128,
              color: KurbaniPalette.gold.withValues(alpha: .12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .18),
                      ),
                    ),
                    child: const Icon(
                      Icons.nightlight_round,
                      color: KurbaniPalette.gold,
                      size: 27,
                    ),
                  ),
                  const Spacer(),
                  _HeroPill(
                    icon: Icons.auto_awesome_rounded,
                    text: 'kurbani_eid'.tr(),
                  ),
                ],
              ),
              const SizedBox(height: 19),
              Text(
                'kurbani_overview_kicker'.tr(),
                style: const TextStyle(
                  color: KurbaniPalette.gold,
                  fontFamily: MyString.rubikMedium,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                projectName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: MyString.poppinsBold,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                activeEvent == null
                    ? 'kurbani_overview_no_active'.tr()
                    : 'kurbani_overview_active'.tr(
                        namedArgs: {'name': activeEvent!.name},
                      ),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .7),
                  fontFamily: MyString.rubikRegular,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _HeroStat(
                    value: activeEvent == null ? '0' : '1',
                    label: 'kurbani_active_label'.tr(),
                  ),
                  const SizedBox(width: 10),
                  _HeroStat(
                    value: '$completedCount',
                    label: 'kurbani_completed_label'.tr(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      children: [
        Icon(icon, size: 13, color: KurbaniPalette.gold),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: MyString.rubikMedium,
            fontSize: 9,
          ),
        ),
      ],
    ),
  );
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: MyString.poppinsBold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .62),
                fontFamily: MyString.rubikRegular,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
