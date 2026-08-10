import 'package:flutter/material.dart';

import 'pack_palette.dart';

class PackCardShell extends StatelessWidget {
  const PackCardShell({
    super.key,
    required this.child,
    this.accent = PackPalette.violet,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.onTap,
  });

  final Widget child;
  final Color accent;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    const radius = BorderRadius.all(Radius.circular(22));

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest.withValues(alpha: dark ? .9 : .82),
        borderRadius: radius,
        border: Border.all(color: accent.withValues(alpha: dark ? .3 : .2)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: dark ? .11 : .07),
            blurRadius: 28,
            spreadRadius: -10,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withValues(alpha: dark ? .13 : .07),
                  Colors.transparent,
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
