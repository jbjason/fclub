import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/model/pack_item.dart';
import '../../data/pack_item_icons.dart';
import 'pack_item_card.dart' show packCheckAccentStart, packCheckAccentEnd;

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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          color: colorScheme.surfaceContainerLowest,
          gradient: checked
              ? LinearGradient(
                  colors: [
                    packCheckAccentEnd.withValues(alpha: isDark ? 0.18 : 0.10),
                    packCheckAccentStart.withValues(alpha: isDark ? 0.12 : 0.06),
                  ],
                )
              : null,
          border: Border.all(
            color: checked
                ? packCheckAccentEnd.withValues(alpha: isDark ? 0.5 : 0.35)
                : colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: checked
              ? [
                  BoxShadow(
                    color: packCheckAccentEnd.withValues(alpha: isDark ? 0.22 : 0.12),
                    blurRadius: 10,
                  ),
                ]
              : null,
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
                  color: checked
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
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
                        colors: [packCheckAccentEnd, packCheckAccentStart],
                      )
                    : null,
                border: checked
                    ? null
                    : Border.all(
                        color: colorScheme.outlineVariant, width: 1.5),
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
    final colorScheme = Theme.of(context).colorScheme;
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
            ? [packCheckAccentEnd, packCheckAccentStart]
            : [
                colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ],
      ).createShader(b),
      child: Icon(
        PackItemIcons.resolve(item.iconCodePoint),
        size: 26.r,
        color: Colors.white,
      ),
    );
  }
}
