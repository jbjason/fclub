import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/club/data/model/payment_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Small read-only colored pill showing a [PaymentStatus].
class ClubStatusBadge extends StatelessWidget {
  const ClubStatusBadge({super.key, required this.status});
  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12.r, color: color),
          SizedBox(width: 4.w),
          Text(
            status.label,
            style: TextStyle(
              fontFamily: MyString.poppinsBold,
              fontWeight: FontWeight.w700,
              fontSize: 11.sp,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
