import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourBreakdownRow extends StatelessWidget {
  const TourBreakdownRow({
    super.key,
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final double value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: isTotal ? MyString.poppinsBold : MyString.poppinsRegular,
      fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
      fontSize: 12.sp,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(CurrencyFormatter.format(value), style: style),
        ],
      ),
    );
  }
}
