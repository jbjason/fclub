import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Big settlement card displayed at the top of the Cost Split tab.
/// Shows surplus or deficit with a glowing ring and per-member amount.
class KurbaniSettlementHero extends StatelessWidget {
  const KurbaniSettlementHero({super.key, required this.summary});

  final KurbaniSummary summary;

  static const _emerald = Color(0xFF10B981);
  static const _rose = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final isDeficit = summary.isDeficit;
    final color = isDeficit ? _rose : _emerald;
    final balance = summary.balance.abs();
    final perMember = summary.perMemberAdjustment;
    final memberCount = summary.memberBalances.length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.04),
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 24.r,
            spreadRadius: 0,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ring progress widget
          SizedBox(
            width: 80.r,
            height: 80.r,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80.r,
                  height: 80.r,
                  child: CircularProgressIndicator(
                    value: summary.spendingProgress,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeWidth: 6.r,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '${(summary.spendingProgress * 100).toInt()}%',
                  style: TextStyle(
                    fontFamily: MyString.poppinsBold,
                    fontSize: 13.sp,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    isDeficit ? '⚠ DEFICIT' : '✓ SURPLUS',
                    style: TextStyle(
                      fontFamily: MyString.poppinsBold,
                      fontSize: 10.sp,
                      color: color,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  CurrencyFormatter.format(balance),
                  style: TextStyle(
                    fontFamily: MyString.poppinsBold,
                    fontSize: 26.sp,
                    color: color,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  isDeficit
                      ? 'Collect ${CurrencyFormatter.format(perMember)} from each of $memberCount members'
                      : 'Refund ${CurrencyFormatter.format(perMember)} to each of $memberCount members',
                  style: TextStyle(
                    fontFamily: MyString.rubikRegular,
                    fontSize: 11.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
