import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourSummaryRow extends StatelessWidget {
  const TourSummaryRow(
      {super.key, required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontFamily: MyString.rubikRegular,
                  fontSize: 12.sp,
                  color: colorScheme.onSurfaceVariant)),
          Text(value,
              style: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  fontSize: 12.sp,
                  color: valueColor ?? colorScheme.onSurface)),
        ],
      ),
    );
  }
}
