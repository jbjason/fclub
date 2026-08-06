import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserGroupsErrorState extends StatelessWidget {
  const UserGroupsErrorState({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'group_list_error'.tr(),
            style: TextStyle(
              fontFamily: MyString.rubikRegular,
              fontSize: 10.5.sp,
              height: 1.4,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        TextButton.icon(
          onPressed: onRetry,
          icon: Icon(Icons.refresh_rounded, size: 17.r),
          label: Text('group_retry'.tr()),
          style: TextButton.styleFrom(foregroundColor: MyColor.primary),
        ),
      ],
    );
  }
}
