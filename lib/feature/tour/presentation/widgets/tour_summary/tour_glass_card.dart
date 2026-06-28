import 'dart:ui';

import 'package:fclub/core/constants/my_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Frosted-glass container reused across stat cards, the summary hero, and
/// settlement cards.
class TourGlassCard extends StatelessWidget {
  const TourGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.accentColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  /// Tints the border glow and shadow. Defaults to [MyColor.primary].
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20.r);
    final accent = accentColor ?? MyColor.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassTint = isDark ? MyColor.black : MyColor.white;
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding ?? EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                glassTint.withValues(alpha: isDark ? 0.32 : 0.6),
                glassTint.withValues(alpha: isDark ? 0.12 : 0.22),
              ],
            ),
            border: Border.all(
              color: accent.withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.18),
                blurRadius: 24.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
