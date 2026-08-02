import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupGatewaySectionLabel extends StatelessWidget {
  const GroupGatewaySectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18.r,
          height: 3.r,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [MyColor.primary, MyColor.tertiary],
            ),
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontFamily: MyString.rubikMedium,
            fontWeight: FontWeight.w600,
            fontSize: 9.5.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 1.15,
          ),
        ),
      ],
    );
  }
}
