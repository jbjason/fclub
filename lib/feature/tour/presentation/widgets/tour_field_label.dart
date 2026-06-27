import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourFieldLabel extends StatelessWidget {
  const TourFieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            fontFamily: MyString.poppinsBold,
            fontSize: 12.sp,
            color: MyColor.onSurfaceVariant));
  }
}
