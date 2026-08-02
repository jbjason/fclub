import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shared presentational building-blocks for the home dashboard stat cards.
///
/// All classes in this file are intentionally generic — they carry no
/// provider logic and can be reused by any stat card on the home screen.
///
/// Public API:
///   • [HomeStatCardShell]   — outer glowing card with gradient & ink ripple
///   • [HomeStatCardIcon]    — square accent icon container (card header)
///   • [HomeStatCardArrow]   — circular trailing arrow (card header)
///   • [HomeStatValueRow]    — three-column stat row with dividers
///   • [HomeStatValueItem]   — single labelled stat value (used inside [HomeStatValueRow])
///   • [HomeStatEmptyHint]   — "no data" placeholder for empty states

// ─────────────────────────────────────────────────────────────────────────────
//  Card shell
// ─────────────────────────────────────────────────────────────────────────────

/// Outer container for a dashboard stat card.
///
/// Provides:
///   • An accent-coloured glow [BoxShadow]
///   • An [InkWell] ripple effect via [Material]
///   • A subtle gradient tint from [accent] (top-left) to transparent
///   • A thin border in [accent] colour
///
/// [isDark] should be `Theme.of(context).brightness == Brightness.dark`
/// and is passed explicitly to avoid an extra [BuildContext] lookup inside
/// the shell.
class HomeStatCardShell extends StatelessWidget {
  const HomeStatCardShell({
    super.key,
    required this.accent,
    required this.isDark,
    required this.onTap,
    required this.child,
  });

  final Color accent;
  final bool isDark;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      // ── Accent glow shadow ────────────────────────────────────────────────
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.28 : 0.14),
            blurRadius: 22,
            spreadRadius: -3,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Material(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              // Gradient bleed from top-left
              gradient: LinearGradient(
                colors: [
                  accent.withValues(alpha: isDark ? 0.16 : 0.08),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: accent.withValues(alpha: isDark ? 0.38 : 0.22),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Header sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Square gradient icon container used in the card header row.
class HomeStatCardIcon extends StatelessWidget {
  const HomeStatCardIcon({
    super.key,
    required this.icon,
    required this.accent,
  });

  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.28),
            accent.withValues(alpha: 0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: accent.withValues(alpha: 0.30),
          width: 1,
        ),
      ),
      child: Icon(icon, color: accent, size: 20.r),
    );
  }
}

/// Circular arrow chip placed at the trailing end of the card header.
class HomeStatCardArrow extends StatelessWidget {
  const HomeStatCardArrow({super.key, required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.r,
      height: 30.r,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: accent.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Icon(Icons.arrow_forward_rounded, color: accent, size: 14.r),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Stat row
// ─────────────────────────────────────────────────────────────────────────────

/// A row of exactly three [HomeStatValueItem] widgets separated by thin
/// vertical dividers.
///
/// Uses [IntrinsicHeight] so the dividers always stretch to the tallest cell.
class HomeStatValueRow extends StatelessWidget {
  const HomeStatValueRow({
    super.key,
    required this.items,
    required this.accent,
  });

  /// Exactly three stat items to display.
  final List<HomeStatValueItem> items;

  /// Divider colour derived from the card's accent colour.
  final Color accent;

  @override
  Widget build(BuildContext context) {
    assert(items.length == 3, 'HomeStatValueRow requires exactly 3 items');

    final dividerColor = accent.withValues(alpha: 0.18);

    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: items[0]),
          VerticalDivider(color: dividerColor, thickness: 1, width: 24.w),
          Expanded(child: items[1]),
          VerticalDivider(color: dividerColor, thickness: 1, width: 24.w),
          Expanded(child: items[2]),
        ],
      ),
    );
  }
}

/// A single labelled stat value — a formatted [value] string in [valueColor]
/// above a muted [label].
class HomeStatValueItem extends StatelessWidget {
  const HomeStatValueItem({
    super.key,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;

  /// Colour applied to the [value] text to convey health/status at a glance.
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: MyString.poppinsBold,
            fontWeight: FontWeight.w700,
            fontSize: 13.5.sp,
            color: valueColor,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontFamily: MyString.rubikRegular,
            fontSize: 10.5.sp,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Empty state
// ─────────────────────────────────────────────────────────────────────────────

/// Shown in place of [HomeStatValueRow] when there is no data for the
/// current period.
class HomeStatEmptyHint extends StatelessWidget {
  const HomeStatEmptyHint({
    super.key,
    required this.message,
    required this.accent,
  });

  final String message;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.info_outline_rounded, size: 14.r, color: accent),
        SizedBox(width: 6.w),
        Text(
          message,
          style: TextStyle(
            fontFamily: MyString.rubikRegular,
            fontSize: 11.5.sp,
            color: accent.withValues(alpha: 0.8),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
