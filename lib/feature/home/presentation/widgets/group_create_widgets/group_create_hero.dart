import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupCreateHero extends StatelessWidget {
  const GroupCreateHero({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.r),
        gradient: LinearGradient(
          colors: [
            MyColor.primary.withValues(alpha: isDark ? 0.30 : 0.15),
            MyColor.tertiary.withValues(alpha: isDark ? 0.15 : 0.07),
            MyColor.secondary.withValues(alpha: isDark ? 0.11 : 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: MyColor.primary.withValues(alpha: isDark ? 0.38 : 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: MyColor.primary.withValues(alpha: isDark ? 0.17 : 0.09),
            blurRadius: 28,
            spreadRadius: -8,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'group_create_hero_eyebrow'.tr(),
                  style: TextStyle(
                    fontFamily: MyString.rubikMedium,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: MyColor.primary,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'group_create_hero_title'.tr(),
                  style: TextStyle(
                    fontFamily: MyString.poppinsBold,
                    fontWeight: FontWeight.w700,
                    fontSize: 22.sp,
                    color: colorScheme.onSurface,
                    height: 1.18,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 7.h),
                Text(
                  'group_create_hero_description'.tr(),
                  style: TextStyle(
                    fontFamily: MyString.rubikRegular,
                    fontSize: 11.5.sp,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            width: 78.r,
            height: 78.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [MyColor.primary, MyColor.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: colorScheme.surfaceContainerLowest,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: MyColor.primary.withValues(alpha: 0.28),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.diversity_3_rounded,
              color: Colors.white,
              size: 34.r,
            ),
          ),
        ],
      ),
    );
  }
}
