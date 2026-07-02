import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourSheetHeader extends StatelessWidget {
  const TourSheetHeader({super.key, required this.step, this.onBack});
  final int step;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
      child: Row(
        children: [
          if (onBack != null) ...[
            GestureDetector(
              onTap: onBack,
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: MyColor.primary, size: 18.r),
            ),
            SizedBox(width: 8.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step == 0 ? 'tour_new'.tr() : 'tour_add_members'.tr(),
                  style: TextStyle(
                      fontFamily: MyString.poppinsBold,
                      fontSize: 17.sp,
                      color: colorScheme.onSurface),
                ),
                Text(
                  step == 0 ? 'tour_step1'.tr() : 'tour_step2'.tr(),
                  style: TextStyle(
                      fontFamily: MyString.rubikRegular,
                      fontSize: 11.sp,
                      color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Row(
            children: List.generate(2, (i) {
              return Container(
                margin: EdgeInsets.only(left: 4.w),
                width: 22.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: i == step
                      ? MyColor.primary
                      : MyColor.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
