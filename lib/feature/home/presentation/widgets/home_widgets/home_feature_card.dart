import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/home/presentation/widgets/home_widgets/home_feature_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A tappable card representing a single feature on the home dashboard.
///
/// Each card renders an accent-tinted icon container, the feature title,
/// a short subtitle, and a trailing circular arrow. The card's gradient
/// tint uses the [HomeFeatureItem.accent] colour and automatically adjusts
/// its opacity for dark and light mode.
///
/// Interaction: the card uses [Material] + [InkWell] so the ripple respects
/// the card's rounded corners without clipping artifacts.
class HomeFeatureCard extends StatelessWidget {
  const HomeFeatureCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  /// Feature metadata to display.
  final HomeFeatureItem item;

  /// Callback invoked when the card is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              // Subtle accent tint that bleeds from top-left
              gradient: LinearGradient(
                colors: [
                  item.accent.withValues(alpha: isDark ? 0.13 : 0.06),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.55),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // ── Left: accent icon box ──────────────────────────
                _FeatureIcon(accent: item.accent, icon: item.icon),
                SizedBox(width: 16.w),
                // ── Centre: title + subtitle ───────────────────────
                Expanded(
                  child: _FeatureLabel(
                    title: item.title.tr(),
                    subtitle: item.subtitle.tr(),
                    colorScheme: colorScheme,
                  ),
                ),
                // ── Right: directional arrow ───────────────────────
                _TrailingArrow(accent: item.accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Private sub-widgets ─────────────────────────────────────────────────────

/// Square icon container with a gradient background and a tinted border,
/// both derived from [accent].
class _FeatureIcon extends StatelessWidget {
  const _FeatureIcon({required this.accent, required this.icon});

  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52.r,
      height: 52.r,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.28),
            accent.withValues(alpha: 0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: accent.withValues(alpha: 0.32),
          width: 1,
        ),
      ),
      child: Icon(icon, color: accent, size: 24.r),
    );
  }
}

/// Stacked title + subtitle text column.
class _FeatureLabel extends StatelessWidget {
  const _FeatureLabel({
    required this.title,
    required this.subtitle,
    required this.colorScheme,
  });

  final String title;
  final String subtitle;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: MyString.poppinsMedium,
            fontWeight: FontWeight.w600,
            fontSize: 14.5.sp,
            color: colorScheme.onSurface,
            letterSpacing: 0.1,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: MyString.rubikRegular,
            fontSize: 11.5.sp,
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/// Small circular button-shaped arrow that acts as a visual tap cue.
class _TrailingArrow extends StatelessWidget {
  const _TrailingArrow({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34.r,
      height: 34.r,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: accent.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Icon(
        Icons.arrow_forward_rounded,
        color: accent,
        size: 16.r,
      ),
    );
  }
}
