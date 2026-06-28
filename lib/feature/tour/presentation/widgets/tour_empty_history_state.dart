import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourEmptyHistoryState extends StatelessWidget {
  const TourEmptyHistoryState({super.key, required this.onNew});
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.card_travel_rounded,
              size: 64.r,
              color: MyColor.primary.withValues(alpha: 0.2)),
          SizedBox(height: 16.h),
          Text('No trips yet',
              style: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  fontSize: 16.sp,
                  color: colorScheme.onSurface)),
          SizedBox(height: 6.h),
          Text(
            'Tap the button below to start your\nfirst trip management.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: MyString.rubikRegular,
                fontSize: 13.sp,
                color: colorScheme.onSurfaceVariant,
                height: 1.5),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: onNew,
            icon: const Icon(Icons.add_rounded),
            label: Text('Start New Tour',
                style: TextStyle(
                    fontFamily: MyString.poppinsBold, fontSize: 13.sp)),
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColor.primary,
              foregroundColor: Colors.white,
              padding:
                  EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r)),
            ),
          ),
        ],
      ),
    );
  }
}
