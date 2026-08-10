import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/pack_check/data/model/pack_session.dart';
import 'package:flutter/material.dart';

import '../shared/pack_palette.dart';

class PackHistoryHero extends StatelessWidget {
  const PackHistoryHero({
    super.key,
    required this.activeSession,
    required this.completedCount,
  });

  final PackSession? activeSession;
  final int completedCount;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: PackPalette.heroGradient,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: PackPalette.violet.withValues(alpha: .2),
          blurRadius: 36,
          spreadRadius: -10,
          offset: const Offset(0, 18),
        ),
      ],
    ),
    child: Stack(
      children: [
        Positioned(
          right: -28,
          top: -32,
          child: Icon(
            Icons.backpack_rounded,
            color: Colors.white.withValues(alpha: .08),
            size: 150,
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
                      color: Colors.white.withValues(alpha: .16),
                    ),
                  ),
                  child: const Icon(
                    Icons.luggage_rounded,
                    color: PackPalette.cyan,
                    size: 28,
                  ),
                ),
                const Spacer(),
                _HeroPill(
                  icon: activeSession == null
                      ? Icons.auto_awesome_rounded
                      : Icons.bolt_rounded,
                  text: activeSession == null
                      ? 'history'.tr()
                      : 'pack_active_status'.tr(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'pack_feature_subtitle'.tr().toUpperCase(),
              style: const TextStyle(
                color: PackPalette.cyan,
                fontFamily: MyString.rubikMedium,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'pack_feature_title'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontFamily: MyString.poppinsBold,
                fontSize: 27,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _HeroStat(
                  value: activeSession == null ? '0' : '1',
                  label: 'pack_active_status'.tr(),
                ),
                const SizedBox(width: 10),
                _HeroStat(value: '$completedCount', label: 'history'.tr()),
              ],
            ),
          ],
        ),
      ],
    ),
  );
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: PackPalette.cyan),
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
              fontSize: 20,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .62),
                fontFamily: MyString.rubikRegular,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
