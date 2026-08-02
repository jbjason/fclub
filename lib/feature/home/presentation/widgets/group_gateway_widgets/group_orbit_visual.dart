import 'package:fclub/core/constants/my_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupOrbitVisual extends StatelessWidget {
  const GroupOrbitVisual({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = MyColor.primary.withValues(alpha: isDark ? 0.36 : 0.24);

    return SizedBox(
      width: 172.r,
      height: 126.r,
      child: CustomPaint(
        painter: _OrbitPainter(lineColor),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _Node(
              size: 70.r,
              color: MyColor.primary,
              icon: Icons.groups_2_rounded,
              iconSize: 31.r,
            ),
            Positioned(
              top: 2.r,
              left: 12.r,
              child: _Node(
                size: 38.r,
                color: MyColor.secondary,
                icon: Icons.savings_rounded,
                iconSize: 17.r,
              ),
            ),
            Positioned(
              top: 6.r,
              right: 8.r,
              child: _Node(
                size: 34.r,
                color: MyColor.tertiary,
                icon: Icons.favorite_rounded,
                iconSize: 15.r,
              ),
            ),
            Positioned(
              bottom: 2.r,
              left: 22.r,
              child: _Node(
                size: 31.r,
                color: MyColor.warning,
                icon: Icons.flight_takeoff_rounded,
                iconSize: 14.r,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 18.r,
              child: _Node(
                size: 39.r,
                color: MyColor.success,
                icon: Icons.shield_rounded,
                iconSize: 17.r,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({
    required this.size,
    required this.color,
    required this.icon,
    required this.iconSize,
  });

  final double size;
  final Color color;
  final IconData icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surfaceContainerLowest;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.95),
            color.withValues(alpha: 0.68),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: surface, width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: iconSize),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  const _OrbitPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width - 24,
        height: size.height - 20,
      ),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.22, size.height * 0.21),
      Offset(size.width * 0.74, size.height * 0.78),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.78, size.height * 0.20),
      Offset(size.width * 0.28, size.height * 0.78),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) =>
      oldDelegate.color != color;
}
