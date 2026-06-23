import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Colored initials circle, no image required.
class TourMemberAvatar extends StatelessWidget {
  const TourMemberAvatar({
    super.key,
    required this.name,
    required this.colorIndex,
    this.radius,
  });

  final String name;
  final int colorIndex;
  final double? radius;

  static const List<Color> palette = [
    MyColor.primary,
    MyColor.secondary,
    MyColor.tertiary,
    MyColor.warning,
    MyColor.success,
    MyColor.logGradient1Color,
    MyColor.logGradient2Color,
    MyColor.logGradient3Color,
  ];

  static Color colorFor(int index) => palette[index % palette.length];

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(colorIndex);
    final effectiveRadius = radius ?? 20.r;
    return Semantics(
      label: name,
      child: CircleAvatar(
        radius: effectiveRadius,
        backgroundColor: color.withValues(alpha: 0.15),
        child: Text(
          _initials,
          style: TextStyle(
            color: color,
            fontFamily: MyString.poppinsBold,
            fontWeight: FontWeight.w700,
            fontSize: effectiveRadius * 0.7,
          ),
        ),
      ),
    );
  }
}
