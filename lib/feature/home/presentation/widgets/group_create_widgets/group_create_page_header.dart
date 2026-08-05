import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupCreatePageHeader extends StatelessWidget {
  const GroupCreatePageHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Material(
          color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(14.r),
          child: InkWell(
            key: const Key('group-create-back-button'),
            onTap: onBack,
            borderRadius: BorderRadius.circular(14.r),
            child: SizedBox(
              width: 42.r,
              height: 42.r,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: colorScheme.onSurface,
                size: 18.r,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'group_create_page_title'.tr(),
                style: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                'group_create_page_subtitle'.tr(),
                style: TextStyle(
                  fontFamily: MyString.rubikRegular,
                  fontSize: 10.5.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: MyColor.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: MyColor.success.withValues(alpha: 0.24)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_rounded, color: MyColor.success, size: 12.r),
              SizedBox(width: 4.w),
              Text(
                'group_create_private_badge'.tr(),
                style: TextStyle(
                  fontFamily: MyString.rubikMedium,
                  fontSize: 8.5.sp,
                  fontWeight: FontWeight.w600,
                  color: MyColor.success,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
