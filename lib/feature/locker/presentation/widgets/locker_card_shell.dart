import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable Locker-feature card chrome mirroring the Home dashboard's glass
/// card language: a subtle accent gradient bleeding from the top-left, a
/// thin accent border on a [ColorScheme.surfaceContainerLowest] base, and
/// an ink ripple for tappable cards.
class LockerCardShell extends StatelessWidget {
  const LockerCardShell({
    super.key,
    required this.accent,
    required this.child,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.margin,
  });

  final Color accent;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
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

    return margin == null ? card : Container(margin: margin, child: card);
  }
}

/// Accent-tinted square icon container matching Home's stat-card icon style.
class LockerCardIcon extends StatelessWidget {
  const LockerCardIcon({
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
