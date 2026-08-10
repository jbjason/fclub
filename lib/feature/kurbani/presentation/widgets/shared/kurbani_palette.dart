import 'package:flutter/material.dart';

abstract final class KurbaniPalette {
  static const emerald = Color(0xFF10B981);
  static const deepEmerald = Color(0xFF064E3B);
  static const gold = Color(0xFFF59E0B);
  static const cyan = Color(0xFF06B6D4);
  static const violet = Color(0xFFA855F7);
  static const rose = Color(0xFFF43F5E);
  static const midnight = Color(0xFF11102A);

  static const heroGradient = LinearGradient(
    colors: [Color(0xFF052E2B), Color(0xFF164E63), Color(0xFF4C1D95)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
