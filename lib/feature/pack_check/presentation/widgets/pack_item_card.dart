import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/model/pack_item.dart';

/// A tappable icon card representing a single packable item.
///
/// When [isPacked] is true the card glows with a neon gradient border.
/// Long-press on custom items triggers [onLongPress] (delete callback).
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: packed
                  ? [
                      const Color(0xFF1E0A3C),
                      const Color(0xFF0A1F3C),
                    ]
                  : [
                      const Color(0xFF12102A),
                      const Color(0xFF0E0E24),
                    ],
            ),
            // Glowing border via box shadow + border simulation
            boxShadow: packed
                ? [
                    BoxShadow(
                      color: const Color(0xFFA855F7).withOpacity(0.55),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: const Color(0xFF06B6D4).withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              // Gradient border ring when packed
              if (packed)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18.r),
                    child: CustomPaint(painter: _GradientBorderPainter()),
                  ),
                ),
              // Glassmorphism inner layer
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17.r),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: packed
                            ? Colors.white.withOpacity(0.04)
                            : Colors.white.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(17.r),
                      ),
                    ),
                  ),
                ),
              ),
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
                              ? Colors.white
                              : Colors.white.withOpacity(0.55),
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
                        colors: [Color(0xFFA855F7), Color(0xFF06B6D4)],
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
            ? [const Color(0xFFA855F7), const Color(0xFF06B6D4)]
            : [Colors.white38, Colors.white24],
      ).createShader(bounds),
      child: Icon(
        IconData(item.iconCodePoint, fontFamily: 'MaterialIcons'),
        size: 30.r,
        color: Colors.white,
      ),
    );
  }
}

/// Paints a 1.5-px gradient border around the card when selected.
class _GradientBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const gradient = LinearGradient(
      colors: [Color(0xFFA855F7), Color(0xFF06B6D4), Color(0xFFA855F7)],
      stops: [0.0, 0.5, 1.0],
    );
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final rRect = RRect.fromRectAndRadius(rect.deflate(0.75), const Radius.circular(18));
    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
