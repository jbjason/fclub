import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourEmptyHistoryState extends StatelessWidget {
  const TourEmptyHistoryState({
    super.key,
    required this.onNew,
    this.showAction = true,
  });
  final VoidCallback onNew;
  final bool showAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.card_travel_rounded,
            size: 64.r,
            color: MyColor.primary.withValues(alpha: 0.2),
          ),
          SizedBox(height: 16.h),
          Text(
            'tour_no_trips'.tr(),
            style: TextStyle(
              fontFamily: MyString.poppinsBold,
              fontSize: 16.sp,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'tour_empty_state'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: MyString.rubikRegular,
              fontSize: 13.sp,
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.h),
          if (showAction)
            ElevatedButton.icon(
              onPressed: onNew,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                'tour_start'.tr(),
                style: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  fontSize: 13.sp,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColor.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
