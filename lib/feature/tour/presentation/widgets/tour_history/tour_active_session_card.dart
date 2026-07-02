import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/tour/data/model/tour_session.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_card_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourActiveSessionCard extends StatelessWidget {
  const TourActiveSessionCard({
    super.key,
    required this.session,
    required this.onResume,
    this.onFinish,
    this.onDelete,
  });
  final TourSession session;
  final VoidCallback onResume;
  final VoidCallback? onFinish;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TourCardShell(
      accent: MyColor.primary,
      glow: true,
      onTap: onResume,
      borderRadius: BorderRadius.circular(18.r),
      padding: EdgeInsets.all(14.r),
      child: Row(
        children: [
          TourCardIcon(
            icon: Icons.card_travel_rounded,
            accent: MyColor.primary,
            size: 44,
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
                    color: MyColor.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'in_progress'.tr(),
                    style: TextStyle(
                      fontFamily: MyString.poppinsBold,
                      fontSize: 9.sp,
                      color: MyColor.primary,
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
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${session.members.length} members · ${CurrencyFormatter.format(session.totalSpent)} spent',
                  style: TextStyle(
                    fontFamily: MyString.rubikRegular,
                    fontSize: 11.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: MyColor.primary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              'resume'.tr(),
              style: TextStyle(
                fontFamily: MyString.poppinsBold,
                fontSize: 12.sp,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded,
                color: colorScheme.onSurfaceVariant, size: 18.r),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r)),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'finish',
                child: Row(children: [
                  Icon(Icons.done_all_rounded,
                      color: MyColor.success, size: 18.r),
                  SizedBox(width: 10.w),
                  Text('finish_session'.tr(),
                      style: TextStyle(color: MyColor.success)),
                ]),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline_rounded,
                      color: MyColor.error, size: 18.r),
                  SizedBox(width: 10.w),
                  Text('delete_session'.tr(),
                      style: TextStyle(color: MyColor.error)),
                ]),
              ),
            ],
            onSelected: (v) {
              if (v == 'finish') onFinish?.call();
              if (v == 'delete') onDelete?.call();
            },
          ),
        ],
      ),
    );
  }
}
