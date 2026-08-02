import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupChoiceDivider extends StatelessWidget {
  const GroupChoiceDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: colorScheme.outlineVariant.withValues(alpha: 0.65),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            'group_or'.tr(),
            style: TextStyle(
              fontFamily: MyString.rubikMedium,
              fontWeight: FontWeight.w600,
              fontSize: 9.sp,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.3,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: colorScheme.outlineVariant.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }
}
