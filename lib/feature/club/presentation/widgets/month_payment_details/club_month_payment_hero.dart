import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/club/data/model/club_month_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClubMonthPaymentHero extends StatelessWidget {
  const ClubMonthPaymentHero({
    super.key,
    required this.summary,
    required this.paymentCount,
  });

  final ClubMonthSummary summary;
  final int paymentCount;

  @override
  Widget build(BuildContext context) {
    final monthLabel = MaterialLocalizations.of(
      context,
    ).formatMonthYear(summary.month);

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF5A37D6), Color(0xFF7A55E8), Color(0xFF009F9A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: MyColor.primary.withValues(alpha: .24),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .20),
                  ),
                ),
                child: Text(
                  monthLabel,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: MyString.poppinsBold,
                    fontSize: 10.sp,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.receipt_long_rounded,
                color: Colors.white.withValues(alpha: .88),
                size: 21.r,
              ),
            ],
          ),
          SizedBox(height: 17.h),
          Text(
            CurrencyFormatter.format(summary.collected),
            style: TextStyle(
              color: Colors.white,
              fontFamily: MyString.poppinsBold,
              fontSize: 28.sp,
            ),
          ),
          Text(
            'club_month_collected_target'.tr(
              namedArgs: {'target': CurrencyFormatter.format(summary.target)},
            ),
            style: TextStyle(
              color: Colors.white.withValues(alpha: .76),
              fontFamily: MyString.rubikRegular,
              fontSize: 11.sp,
            ),
          ),
          SizedBox(height: 15.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: LinearProgressIndicator(
              value: summary.progress,
              minHeight: 7.h,
              backgroundColor: Colors.white.withValues(alpha: .18),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          SizedBox(height: 15.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(17.r),
              border: Border.all(color: Colors.white.withValues(alpha: .15)),
            ),
            child: Row(
              children: [
                _metric(
                  label: 'club_payment_pending_amount'.tr(),
                  value: CurrencyFormatter.format(summary.pending),
                ),
                _divider(),
                _metric(
                  label: 'club_payment_rejected_amount'.tr(),
                  value: CurrencyFormatter.format(summary.rejected),
                ),
                _divider(),
                _metric(
                  label: 'club_payment_entries'.tr(),
                  value: '$paymentCount',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric({required String label, required String value}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontFamily: MyString.poppinsBold,
              fontSize: 10.5.sp,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .68),
              fontFamily: MyString.rubikRegular,
              fontSize: 8.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 30.h,
    margin: EdgeInsets.symmetric(horizontal: 9.w),
    color: Colors.white.withValues(alpha: .18),
  );
}
