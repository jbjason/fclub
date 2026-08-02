import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_orbit_visual.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupGatewayHero extends StatelessWidget {
  const GroupGatewayHero({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        gradient: LinearGradient(
          colors: [
            MyColor.primary.withValues(alpha: isDark ? 0.24 : 0.12),
            MyColor.secondary.withValues(alpha: isDark ? 0.10 : 0.05),
            MyColor.tertiary.withValues(alpha: isDark ? 0.08 : 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: MyColor.primary.withValues(alpha: isDark ? 0.36 : 0.20),
        ),
        boxShadow: [
          BoxShadow(
            color: MyColor.primary.withValues(alpha: isDark ? 0.18 : 0.10),
            blurRadius: 28,
            spreadRadius: -8,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final copy = _HeroCopy(colorScheme: colorScheme);
          const visual = GroupOrbitVisual();

          if (constraints.maxWidth >= 520) {
            return Row(
              children: [
                Expanded(child: copy),
                SizedBox(width: 24.w),
                visual,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              copy,
              SizedBox(height: 10.h),
              const Align(alignment: Alignment.center, child: visual),
            ],
          );
        },
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: MyColor.primary.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: MyColor.primary.withValues(alpha: 0.22)),
          ),
          child: Text(
            'group_gateway_eyebrow'.tr(),
            style: TextStyle(
              fontFamily: MyString.rubikMedium,
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
              color: MyColor.primary,
              letterSpacing: 1.1,
            ),
          ),
        ),
        SizedBox(height: 13.h),
        Text(
          'group_gateway_title'.tr(),
          style: TextStyle(
            fontFamily: MyString.poppinsBold,
            fontWeight: FontWeight.w700,
            fontSize: 27.sp,
            color: colorScheme.onSurface,
            height: 1.15,
            letterSpacing: -0.7,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'group_gateway_description'.tr(),
          style: TextStyle(
            fontFamily: MyString.rubikRegular,
            fontSize: 12.5.sp,
            color: colorScheme.onSurfaceVariant,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}
