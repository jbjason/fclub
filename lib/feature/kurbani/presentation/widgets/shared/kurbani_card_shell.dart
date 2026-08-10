import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:flutter/material.dart';

class KurbaniCardShell extends StatelessWidget {
  const KurbaniCardShell({
    super.key,
    required this.child,
    this.accent = KurbaniPalette.emerald,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius = const BorderRadius.all(Radius.circular(22)),
    this.onTap,
  });

  final Widget child;
  final Color accent;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(
          alpha: dark ? .55 : .72,
        ),
        borderRadius: borderRadius,
        border: Border.all(color: accent.withValues(alpha: dark ? .28 : .2)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: dark ? .09 : .07),
            blurRadius: 24,
            spreadRadius: -9,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
