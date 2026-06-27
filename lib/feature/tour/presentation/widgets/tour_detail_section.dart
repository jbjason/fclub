import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourDetailSection extends StatelessWidget {
  const TourDetailSection({super.key, required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontFamily: MyString.poppinsBold,
                fontSize: 13.sp,
                color: MyColor.primary,
                letterSpacing: 0.3)),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
              color: MyColor.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14.r)),
          child: child,
        ),
      ],
    );
  }
}
