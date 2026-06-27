import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/tour/data/model/tour_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourActiveSessionCard extends StatelessWidget {
  const TourActiveSessionCard(
      {super.key, required this.session, required this.onResume});
  final TourSession session;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onResume,
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [MyColor.primary, MyColor.secondary],
          ),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: MyColor.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.card_travel_rounded,
                  color: Colors.white, size: 22.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 7.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'IN PROGRESS',
                      style: TextStyle(
                        fontFamily: MyString.poppinsBold,
                        fontSize: 9.sp,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    session.tourName,
                    style: TextStyle(
                      fontFamily: MyString.poppinsBold,
                      fontSize: 14.sp,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${session.members.length} members · ${CurrencyFormatter.format(session.totalSpent)} spent',
                    style: TextStyle(
                      fontFamily: MyString.rubikRegular,
                      fontSize: 11.sp,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'Resume',
                style: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  fontSize: 12.sp,
                  color: MyColor.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
