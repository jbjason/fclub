import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/tour/presentation/widgets/shared/tour_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourBudgetMeter extends StatelessWidget {
  const TourBudgetMeter({
    super.key,
    required this.budget,
    required this.spent,
    required this.progress,
    required this.isOverBudget,
  });

  final double budget;
  final double spent;
  final double progress;
  final bool isOverBudget;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = isOverBudget ? MyColor.error : TourPalette.ocean;
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(color: accent.withValues(alpha: .22)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.route_rounded, color: accent, size: 18.r),
              SizedBox(width: 7.w),
              Text(
                'tour_budget_journey'.tr(),
                style: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  fontSize: 12.sp,
                ),
              ),
              const Spacer(),
              Text(
                '${CurrencyFormatter.format(spent)} / ${CurrencyFormatter.format(budget)}',
                style: TextStyle(
                  color: accent,
                  fontFamily: MyString.poppinsBold,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 9.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9.h,
              backgroundColor: colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
        ],
      ),
    );
  }
}
