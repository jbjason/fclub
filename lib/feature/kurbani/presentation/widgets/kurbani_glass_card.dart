import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class KurbaniGlassCard extends StatelessWidget {
  const KurbaniGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.accentColor,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? accentColor;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20.r);
    final accent = accentColor ?? const Color(0xFF10B981);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassTint = isDark ? Colors.black : Colors.white;

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding ?? EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: gradient ??
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    glassTint.withValues(alpha: isDark ? 0.3 : 0.55),
                    glassTint.withValues(alpha: isDark ? 0.1 : 0.2),
                  ],
                ),
            border: Border.all(
              color: accent.withValues(alpha: 0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.15),
                blurRadius: 20.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
