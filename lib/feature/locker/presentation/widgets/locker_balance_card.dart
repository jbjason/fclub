import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Hero card for [LockerScreen] — current cash, a quick edit action for the
/// admin-set base balance, and a Collected-vs-Spent breakdown with a
/// progress bar.
class LockerBalanceCard extends StatelessWidget {
  const LockerBalanceCard({
    super.key,
    required this.currentCash,
    required this.collected,
    required this.spent,
    required this.onEditBalance,
  });

  final double currentCash;
  final double collected;
  final double spent;
  final VoidCallback onEditBalance;

  @override
  Widget build(BuildContext context) {
    final isNegative = currentCash < 0;
    final progress = collected <= 0 ? 0.0 : (spent / collected).clamp(0, 1).toDouble();
    final progressColor = isNegative ? MyColor.error : MyColor.success;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MyColor.primary, MyColor.secondary, MyColor.tertiary],
        ),
        boxShadow: [
          BoxShadow(
            color: MyColor.primary.withValues(alpha: 0.3),
            blurRadius: 20.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Cash',
                style: TextStyle(
                  fontFamily: MyString.poppinsMedium,
                  fontSize: 12.sp,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              GestureDetector(
                onTap: onEditBalance,
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.edit_rounded, size: 14.r, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            CurrencyFormatter.format(currentCash),
            style: TextStyle(
              fontFamily: MyString.poppinsBold,
              fontWeight: FontWeight.w800,
              fontSize: 30.sp,
              color: Colors.white,
            ),
          ),
          if (isNegative) ...[
            SizedBox(height: 2.h),
            Text(
              'Spending has exceeded total collected',
              style: TextStyle(fontSize: 11.sp, color: Colors.white.withValues(alpha: 0.85)),
            ),
          ],
          SizedBox(height: 16.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 8.h,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                );
              },
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              _MiniStat(label: 'Collected', amount: collected),
              SizedBox(width: 24.w),
              _MiniStat(label: 'Spent', amount: spent),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.amount});

  final String label;
  final double amount;

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
            fontSize: 14.sp,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: Colors.white.withValues(alpha: 0.8)),
        ),
      ],
    );
  }
}
