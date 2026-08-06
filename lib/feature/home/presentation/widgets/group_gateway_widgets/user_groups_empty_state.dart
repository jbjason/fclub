import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserGroupsEmptyState extends StatelessWidget {
  const UserGroupsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Icon(
            Icons.group_off_outlined,
            size: 20.r,
            color: colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Text(
              'group_list_empty'.tr(),
              style: TextStyle(
                fontFamily: MyString.rubikRegular,
                fontSize: 11.sp,
                height: 1.4,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
