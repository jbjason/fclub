import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupFormSectionCard extends StatelessWidget {
  const GroupFormSectionCard({
    super.key,
    required this.icon,
    required this.accent,
    required this.title,
    required this.description,
    required this.child,
    this.trailing,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String description;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.14 : 0.07),
            blurRadius: 24,
            spreadRadius: -8,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: accent.withValues(alpha: isDark ? 0.30 : 0.18),
          ),
          gradient: LinearGradient(
            colors: [
              accent.withValues(alpha: isDark ? 0.11 : 0.05),
              colorScheme.surfaceContainerLowest,
            ],
            begin: Alignment.topLeft,
            end: Alignment.center,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42.r,
                  height: 42.r,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: accent.withValues(alpha: 0.22)),
                  ),
                  child: Icon(icon, color: accent, size: 20.r),
                ),
                SizedBox(width: 11.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: MyString.poppinsBold,
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          fontFamily: MyString.rubikRegular,
                          fontSize: 10.5.sp,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[SizedBox(width: 8.w), trailing!],
              ],
            ),
            SizedBox(height: 18.h),
            child,
          ],
        ),
      ),
    );
  }
}
