import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/model/pack_item.dart';

/// A single checklist row used in check (return-verify) mode.
///
/// Tapping toggles the [isCheckedBack] state via the supplied [onToggle].
class PackChecklistTile extends StatelessWidget {
  const PackChecklistTile({
    required this.item,
    required this.onToggle,
    super.key,
  });

  final PackItem item;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final checked = item.isCheckedBack;

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          gradient: LinearGradient(
            colors: checked
                ? [
                    const Color(0xFF06B6D4).withOpacity(0.15),
                    const Color(0xFFA855F7).withOpacity(0.1),
                  ]
                : [
                    const Color(0xFF12102A),
                    const Color(0xFF0E0E24),
                  ],
          ),
          border: Border.all(
            color: checked
                ? const Color(0xFF06B6D4).withOpacity(0.45)
                : Colors.white.withOpacity(0.07),
            width: 1,
          ),
          boxShadow: checked
              ? [
                  BoxShadow(
                    color: const Color(0xFF06B6D4).withOpacity(0.2),
                    blurRadius: 10,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Item visual
            _TileVisual(item: item, checked: checked),
            SizedBox(width: 12.w),
            // Name
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  fontFamily: 'Poppins_Medium',
                  fontSize: 14.sp,
                  color: checked ? Colors.white : Colors.white70,
                  decoration: checked ? TextDecoration.none : null,
                ),
              ),
            ),
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24.r,
              height: 24.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: checked
                    ? const LinearGradient(
                        colors: [Color(0xFF06B6D4), Color(0xFFA855F7)],
                      )
                    : null,
                border: checked
                    ? null
                    : Border.all(color: Colors.white30, width: 1.5),
              ),
              child: checked
                  ? Icon(Icons.check_rounded, color: Colors.white, size: 14.r)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _TileVisual extends StatelessWidget {
  const _TileVisual({required this.item, required this.checked});

  final PackItem item;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    if (item.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Image.file(
          File(item.imagePath!),
          width: 32.r,
          height: 32.r,
          fit: BoxFit.cover,
        ),
      );
    }
    return ShaderMask(
      shaderCallback: (b) => LinearGradient(
        colors: checked
            ? [const Color(0xFF06B6D4), const Color(0xFFA855F7)]
            : [Colors.white38, Colors.white24],
      ).createShader(b),
      child: Icon(
        IconData(item.iconCodePoint, fontFamily: 'MaterialIcons'),
        size: 26.r,
        color: Colors.white,
      ),
    );
  }
}
