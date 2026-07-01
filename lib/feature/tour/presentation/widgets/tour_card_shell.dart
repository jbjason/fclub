import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable Tour-feature card chrome mirroring the Home dashboard's glass
/// card language: a subtle accent gradient bleeding from the top-left, a
/// thin accent border on a [ColorScheme.surfaceContainerLowest] base, and
/// (optionally) an ink ripple + accent glow shadow for tappable cards.
class TourCardShell extends StatelessWidget {
  const TourCardShell({
    super.key,
    required this.accent,
    required this.child,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.glow = false,
    this.margin,
  });

  final Color accent;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  /// Adds an accent-tinted glow shadow around the card — reserved for
  /// hero/standout cards so it doesn't compete with dense list cards.
  final bool glow;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(16.r);

    final card = Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: padding ?? EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              colors: [
                accent.withValues(alpha: isDark ? 0.14 : 0.06),
                Colors.transparent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: accent.withValues(alpha: isDark ? 0.32 : 0.20),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (!glow) {
      return margin == null ? card : Container(margin: margin, child: card);
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.28 : 0.14),
            blurRadius: 22,
            spreadRadius: -3,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: card,
    );
  }
}

/// Accent-tinted square icon container matching Home's stat-card icon style.
class TourCardIcon extends StatelessWidget {
  const TourCardIcon({
    super.key,
    required this.icon,
    required this.accent,
    this.size = 44,
  });

  final IconData icon;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.28),
            accent.withValues(alpha: 0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(color: accent.withValues(alpha: 0.30), width: 1),
      ),
      child: Icon(icon, color: accent, size: (size * 0.45).r),
    );
  }
}

/// Circular trailing chip matching Home's stat-card arrow style.
class TourCardArrow extends StatelessWidget {
  const TourCardArrow({
    super.key,
    required this.accent,
    this.icon = Icons.arrow_forward_rounded,
  });

  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.r,
      height: 30.r,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: accent.withValues(alpha: 0.22), width: 1),
      ),
      child: Icon(icon, color: accent, size: 14.r),
    );
  }
}
