import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/club/data/model/club_constants.dart';
import 'package:fclub/feature/club/data/model/club_month_summary.dart';
import 'package:fclub/feature/club/presentation/widgets/club_card_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClubMonthSummaryCard extends StatelessWidget {
  const ClubMonthSummaryCard({super.key, required this.summary, this.onTap});

  final ClubMonthSummary summary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final monthLabel = MaterialLocalizations.of(
      context,
    ).formatMonthYear(summary.month);
    return ClubCardShell(
      accent: MyColor.primary,
      onTap: onTap,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(15.w),
      child: Column(
        children: [
          Row(
            children: [
              ClubCardIcon(
                icon: Icons.calendar_month_rounded,
                accent: MyColor.primary,
                size: 42,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      monthLabel,
                      style: TextStyle(
                        fontFamily: MyString.poppinsBold,
                        fontSize: 14.sp,
                        color: colors.onSurface,
                      ),
                    ),
                    Text(
                      'club_month_member_target'.tr(
                        namedArgs: {
                          'count': '${summary.memberCount}',
                          'amount': CurrencyFormatter.format(
                            ClubConstants.monthlyTargetPerMember,
                          ),
                        },
                      ),
                      style: TextStyle(
                        fontFamily: MyString.rubikRegular,
                        fontSize: 10.sp,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(summary.progress * 100).round()}%',
                    style: TextStyle(
                      fontFamily: MyString.poppinsBold,
                      fontSize: 15.sp,
                      color: MyColor.primary,
                    ),
                  ),
                  if (onTap != null) ...[
                    SizedBox(width: 2.w),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20.r,
                      color: MyColor.primary,
                    ),
                  ],
                ],
              ),
            ],
          ),
          SizedBox(height: 13.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: summary.progress,
              minHeight: 6.h,
              backgroundColor: MyColor.primary.withValues(alpha: .1),
              valueColor: const AlwaysStoppedAnimation(MyColor.primary),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _Metric(
                label: 'collected'.tr(),
                amount: summary.collected,
                color: MyColor.success,
              ),
              _Metric(
                label: 'club_status_pending'.tr(),
                amount: summary.pending,
                color: MyColor.warning,
              ),
              _Metric(
                label: 'club_outstanding'.tr(),
                amount: summary.outstanding,
                color: MyColor.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            CurrencyFormatter.format(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: MyString.poppinsBold,
              fontSize: 10.5.sp,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: MyString.rubikRegular,
              fontSize: 8.5.sp,
              color: color.withValues(alpha: .85),
            ),
          ),
        ],
      ),
    );
  }
}
