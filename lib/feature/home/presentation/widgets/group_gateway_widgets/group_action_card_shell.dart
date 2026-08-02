import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shared visual shell for the gateway's join and create actions.
class GroupActionCardShell extends StatelessWidget {
  const GroupActionCardShell({
    super.key,
    required this.accent,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.child,
  });

  final Color accent;
  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.16 : 0.08),
            blurRadius: 26,
            spreadRadius: -8,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24.r),
        child: Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            gradient: LinearGradient(
              colors: [
                accent.withValues(alpha: isDark ? 0.13 : 0.06),
                Colors.transparent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: accent.withValues(alpha: isDark ? 0.32 : 0.19),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: accent.withValues(alpha: 0.24)),
                    ),
                    child: Icon(icon, color: accent, size: 23.r),
                  ),
                  SizedBox(width: 13.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eyebrow,
                          style: TextStyle(
                            fontFamily: MyString.rubikMedium,
                            fontWeight: FontWeight.w600,
                            fontSize: 8.5.sp,
                            color: accent,
                            letterSpacing: 1.1,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: MyString.poppinsBold,
                            fontWeight: FontWeight.w700,
                            fontSize: 18.sp,
                            color: colorScheme.onSurface,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                description,
                style: TextStyle(
                  fontFamily: MyString.rubikRegular,
                  fontSize: 12.sp,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 17.h),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
