import 'package:flutter/material.dart';

class PackPalette {
  const PackPalette._();

  static const violet = Color(0xFFA855F7);
  static const cyan = Color(0xFF06B6D4);
  static const indigo = Color(0xFF4F46E5);
  static const emerald = Color(0xFF10B981);
  static const amber = Color(0xFFF59E0B);
  static const rose = Color(0xFFF43F5E);

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF17112E), Color(0xFF3B1E72), Color(0xFF075D71)],
    stops: [0, .52, 1],
  );

  static const actionGradient = LinearGradient(colors: [violet, indigo, cyan]);
}
