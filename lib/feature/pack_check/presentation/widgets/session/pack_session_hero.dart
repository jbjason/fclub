import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/pack_check/data/model/pack_session.dart';
import 'package:flutter/material.dart';

import '../shared/pack_palette.dart';

class PackSessionHero extends StatelessWidget {
  const PackSessionHero({
    super.key,
    required this.session,
    required this.isCheckMode,
    required this.isDraft,
    required this.onPackTap,
  });

  final PackSession session;
  final bool isCheckMode;
  final bool isDraft;
  final VoidCallback onPackTap;

  @override
  Widget build(BuildContext context) {
    final current = isCheckMode
        ? session.checkedBackCount
        : session.packedCount;
    final total = isCheckMode ? session.packedCount : session.items.length;
    final progress = total == 0 ? 0.0 : current / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: PackPalette.heroGradient,
        borderRadius: BorderRadius.circular(29),
        boxShadow: [
          BoxShadow(
            color: (isCheckMode ? PackPalette.cyan : PackPalette.violet)
                .withValues(alpha: .22),
            blurRadius: 34,
            spreadRadius: -10,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -22,
            child: Icon(
              isCheckMode ? Icons.fact_check_rounded : Icons.backpack_rounded,
              size: 128,
              color: Colors.white.withValues(alpha: .08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Icon(
                      isCheckMode
                          ? Icons.playlist_add_check_circle_rounded
                          : Icons.luggage_rounded,
                      color: isCheckMode
                          ? PackPalette.cyan
                          : PackPalette.violet,
                    ),
                  ),
                  const Spacer(),
                  _StatusPill(isDraft: isDraft),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                session.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: MyString.poppinsBold,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isCheckMode
                    ? 'pack_count_verified'.tr(
                        namedArgs: {
                          'checked': '${session.checkedBackCount}',
                          'packed': '${session.packedCount}',
                        },
                      )
                    : 'pack_count_selected'.tr(
                        namedArgs: {
                          'packed': '${session.packedCount}',
                          'total': '${session.items.length}',
                        },
                      ),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .65),
                  fontFamily: MyString.rubikRegular,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 17),
              _StepRail(isCheckMode: isCheckMode, onPackTap: onPackTap),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 420),
                        curve: Curves.easeOutCubic,
                        builder: (_, value, child) => LinearProgressIndicator(
                          value: value,
                          minHeight: 7,
                          backgroundColor: Colors.white.withValues(alpha: .11),
                          valueColor: AlwaysStoppedAnimation(
                            isCheckMode ? PackPalette.cyan : PackPalette.violet,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: MyString.poppinsBold,
                      fontSize: 12,
                    ),
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isDraft});

  final bool isDraft;

  @override
  Widget build(BuildContext context) {
    final accent = isDraft ? PackPalette.amber : PackPalette.emerald;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: accent.withValues(alpha: .35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            isDraft ? 'pack_draft'.tr() : 'pack_active_status'.tr(),
            style: TextStyle(
              color: accent,
              fontFamily: MyString.rubikMedium,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRail extends StatelessWidget {
  const _StepRail({required this.isCheckMode, required this.onPackTap});

  final bool isCheckMode;
  final VoidCallback onPackTap;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _Step(
          number: '1',
          label: 'pack_step_pack'.tr(),
          accent: PackPalette.violet,
          selected: !isCheckMode,
          complete: isCheckMode,
          onTap: onPackTap,
        ),
      ),
      Container(
        width: 28,
        height: 2,
        color: isCheckMode ? PackPalette.cyan : Colors.white24,
      ),
      Expanded(
        child: _Step(
          number: '2',
          label: 'pack_step_check'.tr(),
          accent: PackPalette.cyan,
          selected: isCheckMode,
        ),
      ),
    ],
  );
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.label,
    required this.accent,
    required this.selected,
    this.complete = false,
    this.onTap,
  });

  final String number;
  final String label;
  final Color accent;
  final bool selected;
  final bool complete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: (selected || complete)
            ? accent.withValues(alpha: .16)
            : Colors.white.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (selected || complete)
              ? accent.withValues(alpha: .42)
              : Colors.white12,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            child: complete
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                : Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: MyString.poppinsBold,
                      fontSize: 10,
                    ),
                  ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: MyString.rubikMedium,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
