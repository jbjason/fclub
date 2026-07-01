import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/model/pack_item.dart';
import '../../data/pack_item_icons.dart';

/// Pack Check's signature dual-accent — violet to cyan — used to mark
/// packed/checked state across the feature.
const packCheckAccentStart = Color(0xFFA855F7);
const packCheckAccentEnd = Color(0xFF06B6D4);

/// A tappable icon card representing a single packable item.
///
/// When [isPacked] is true the card glows with the violet → cyan accent
/// gradient border. Long-press on custom items triggers [onLongPress]
/// (delete callback).
class PackItemCard extends StatefulWidget {
  const PackItemCard({
    required this.item,
    required this.onTap,
    this.onLongPress,
    super.key,
  });

  final PackItem item;
  final VoidCallback onTap;

  /// Supplied only for custom items — shows a delete hint on long-press.
  final VoidCallback? onLongPress;

  @override
  State<PackItemCard> createState() => _PackItemCardState();
}

class _PackItemCardState extends State<PackItemCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.08,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onTapDown(TapDownDetails _) => _ctrl.forward();
  Future<void> _onTapUp(TapUpDetails _) async {
    await _ctrl.reverse();
    widget.onTap();
  }

  Future<void> _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    final packed = widget.item.isPacked;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            color: colorScheme.surfaceContainerLowest,
            gradient: packed
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      packCheckAccentStart.withValues(alpha: isDark ? 0.20 : 0.10),
                      packCheckAccentEnd.withValues(alpha: isDark ? 0.12 : 0.05),
                    ],
                  )
                : null,
            border: Border.all(
              color: packed
                  ? packCheckAccentEnd.withValues(alpha: isDark ? 0.55 : 0.4)
                  : colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: packed
                ? [
                    BoxShadow(
                      color: packCheckAccentStart.withValues(alpha: isDark ? 0.28 : 0.16),
                      blurRadius: 14,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Content
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 10.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon or photo
                      _ItemVisual(item: widget.item, isPacked: packed),
                      SizedBox(height: 6.h),
                      // Name label
                      Text(
                        widget.item.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins_Medium',
                          fontSize: 10.sp,
                          height: 1.2,
                          color: packed
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Packed checkmark badge
              if (packed)
                Positioned(
                  top: 5.r,
                  right: 5.r,
                  child: Container(
                    width: 14.r,
                    height: 14.r,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [packCheckAccentStart, packCheckAccentEnd],
                      ),
                    ),
                    child: Icon(
                      Icons.check,
                      size: 9.r,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders the item's photo or icon.
class _ItemVisual extends StatelessWidget {
  const _ItemVisual({required this.item, required this.isPacked});

  final PackItem item;
  final bool isPacked;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (item.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Image.file(
          File(item.imagePath!),
          width: 38.r,
          height: 38.r,
          fit: BoxFit.cover,
        ),
      );
    }
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: isPacked
            ? [packCheckAccentStart, packCheckAccentEnd]
            : [
                colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ],
      ).createShader(bounds),
      child: Icon(
        PackItemIcons.resolve(item.iconCodePoint),
        size: 30.r,
        color: Colors.white,
      ),
    );
  }
}
