import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

/// One row on [ClubMonthlyOverviewScreen] — a month with its mini stats.
/// Tapping it drills into [ClubMonthDetailScreen] for that month.
class ClubMonthOverviewTile extends StatelessWidget {
  const ClubMonthOverviewTile({
    super.key,
    required this.month,
    required this.collected,
    required this.due,
    required this.advance,
    required this.memberCount,
    required this.onTap,
  });

  final DateTime month;
  final double collected;
  final double due;
  final double advance;
  final int memberCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: MyColor.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.calendar_month_rounded,
                    color: MyColor.primary, size: 20.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(month),
                      style: TextStyle(
                        fontFamily: MyString.poppinsBold,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '$memberCount members',
                      style: TextStyle(
                        fontFamily: MyString.rubikRegular,
                        fontSize: 11.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        _MiniStat(label: 'Collected', amount: collected, color: MyColor.success),
                        SizedBox(width: 16.w),
                        _MiniStat(label: 'Due', amount: due, color: MyColor.error),
                        SizedBox(width: 16.w),
                        _MiniStat(label: 'Advance', amount: advance, color: MyColor.warning),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.amount, required this.color});

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          CurrencyFormatter.format(amount),
          style: TextStyle(
            fontFamily: MyString.poppinsBold,
            fontWeight: FontWeight.w700,
            fontSize: 12.sp,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: MyString.rubikRegular,
            fontSize: 9.sp,
            color: color.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
