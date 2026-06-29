import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Decorative brand header shown at the top of the home dashboard.
///
/// Renders the Fundora wallet icon, app name, version badge, a bold
/// headline, and a short tagline — all inside a gradient-tinted
/// container that adapts to both dark and light themes.
///
/// This widget is entirely presentational and carries no business logic.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MyColor.primary.withValues(alpha: isDark ? 0.22 : 0.10),
            MyColor.secondary.withValues(alpha: isDark ? 0.10 : 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: MyColor.primary.withValues(alpha: isDark ? 0.35 : 0.18),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Brand row ──────────────────────────────────────────────
          Row(
            children: [
              _BrandIcon(),
              SizedBox(width: 10.w),
              Text(
                'Fundora',
                style: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp,
                  color: MyColor.primary,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              _VersionBadge(isDark: isDark),
            ],
          ),
          SizedBox(height: 16.h),
          // ── Headline ───────────────────────────────────────────────
          Text(
            'Your Financial\nCommand Center',
            style: TextStyle(
              fontFamily: MyString.poppinsBold,
              fontWeight: FontWeight.w700,
              fontSize: 22.sp,
              color: colorScheme.onSurface,
              height: 1.28,
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Manage clubs, lockers, tours & more — all in one place.',
            style: TextStyle(
              fontFamily: MyString.rubikRegular,
              fontSize: 12.5.sp,
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Private sub-widgets ─────────────────────────────────────────────────────

/// Circular icon container holding the wallet icon for the brand row.
class _BrandIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: MyColor.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: MyColor.primary.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Icon(
        Icons.account_balance_wallet_rounded,
        color: MyColor.primary,
        size: 20.r,
      ),
    );
  }
}

/// Small pill badge showing the app version string.
class _VersionBadge extends StatelessWidget {
  const _VersionBadge({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: MyColor.primary.withValues(alpha: isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: MyColor.primary.withValues(alpha: isDark ? 0.30 : 0.15),
          width: 0.8,
        ),
      ),
      child: Text(
        'v1.0',
        style: TextStyle(
          fontFamily: MyString.rubikRegular,
          fontSize: 11.sp,
          color: MyColor.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
