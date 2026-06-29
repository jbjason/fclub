import 'dart:math' as math;

import 'package:flutter/material.dart';

class AuthClipper extends CustomClipper<Path> {
  const AuthClipper({this.cornerRadius = 8});

  final double cornerRadius;

  @override
  Path getClip(Size size) {
    final h = size.height, w = size.width;
    final vertices = [
      Offset(8, 4),
      Offset(w + 4, -4),
      Offset(w - 8, h - 4),
      Offset(-4, h + 4),
    ];
    final n = vertices.length;

    // Point at most `cornerRadius` away from `from`, along the edge to `to`.
    Offset towards(Offset from, Offset to) {
      final delta = to - from;
      final r = math.min(cornerRadius, delta.distance / 2);
      return from + delta / delta.distance * r;
    }

    final pIn = <Offset>[];
    final pOut = <Offset>[];
    for (var i = 0; i < n; i++) {
      final curr = vertices[i];
      pIn.add(towards(curr, vertices[(i - 1 + n) % n]));
      pOut.add(towards(curr, vertices[(i + 1) % n]));
    }

    final path = Path()..moveTo(pOut[0].dx, pOut[0].dy);
    for (var i = 1; i <= n; i++) {
      final idx = i % n;
      path.lineTo(pIn[idx].dx, pIn[idx].dy);
      path.quadraticBezierTo(
          vertices[idx].dx, vertices[idx].dy, pOut[idx].dx, pOut[idx].dy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) => false;
}
