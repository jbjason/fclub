import 'package:fclub/core/constants/my_color.dart';
import 'package:flutter/material.dart';

/// Theme-aware ambient colour used behind the group gateway content.
class GroupGatewayBackdrop extends StatelessWidget {
  const GroupGatewayBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: -170,
            right: -120,
            child: _GlowOrb(
              size: 360,
              color: MyColor.primary,
              opacity: isDark ? 0.18 : 0.10,
            ),
          ),
          Positioned(
            top: 260,
            left: -140,
            child: _GlowOrb(
              size: 300,
              color: MyColor.secondary,
              opacity: isDark ? 0.10 : 0.07,
            ),
          ),
          Positioned(
            bottom: -190,
            right: -100,
            child: _GlowOrb(
              size: 360,
              color: MyColor.tertiary,
              opacity: isDark ? 0.12 : 0.07,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
