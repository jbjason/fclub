import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupPrivacyNote extends StatelessWidget {
  const GroupPrivacyNote({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.verified_user_outlined, color: MyColor.success, size: 15.r),
        SizedBox(width: 7.w),
        Flexible(
          child: Text(
            'group_gateway_privacy'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: MyString.rubikRegular,
              fontSize: 10.sp,
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
