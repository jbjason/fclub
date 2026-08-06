import 'package:fclub/core/constants/my_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserGroupsLoading extends StatelessWidget {
  const UserGroupsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 72.h,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20.r,
              height: 20.r,
              child: const CircularProgressIndicator(
                strokeWidth: 2.2,
                color: MyColor.primary,
              ),
            ),
            SizedBox(width: 11.w),
            Text(
              '•••',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
