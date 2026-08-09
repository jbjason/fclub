import 'package:flutter/material.dart';

/// Adds restrained feature-colour light to a normal themed page without
/// changing its layout or blocking gestures.
class FeatureAmbientBackground extends StatelessWidget {
  const FeatureAmbientBackground({
    super.key,
    required this.accent,
    required this.secondaryAccent,
    required this.child,
  });

  final Color accent;
  final Color secondaryAccent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: colors.surface),
        Positioned(
          top: -150,
          right: -115,
          child: _AmbientOrb(
            size: 340,
            color: accent,
            opacity: isDark ? .16 : .10,
          ),
        ),
        Positioned(
          top: 280,
          left: -180,
          child: _AmbientOrb(
            size: 360,
            color: secondaryAccent,
            opacity: isDark ? .10 : .065,
          ),
        ),
        Positioned(
          right: -150,
          bottom: -210,
          child: _AmbientOrb(
            size: 390,
            color: accent,
            opacity: isDark ? .09 : .05,
          ),
        ),
        child,
      ],
    );
  }
}

class _AmbientOrb extends StatelessWidget {
  const _AmbientOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: opacity),
                color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
