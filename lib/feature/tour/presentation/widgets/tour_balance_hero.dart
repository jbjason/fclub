import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Animated circular indicator showing how much of the collected money
/// remains as surplus (or how deep the deficit is).
class TourBalanceHero extends StatelessWidget {
  const TourBalanceHero({
    super.key,
    required this.balance,
    required this.totalCollected,
  });

  final double balance;
  final double totalCollected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSurplus = balance >= 0;
    final color = isSurplus ? MyColor.success : MyColor.error;
    final progress = totalCollected <= 0
        ? 0.0
        : (1 - (balance.abs() / totalCollected)).clamp(0, 1).toDouble();

    return TourGlassCard(
      padding: EdgeInsets.all(24.w),
      accentColor: color,
      child: Column(
        children: [
          SizedBox(
            height: 140.h,
            width: 140.h,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 140.h,
                      width: 140.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 24.r,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 140.h,
                      width: 140.h,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 10.w,
                        strokeCap: StrokeCap.round,
                        backgroundColor: colorScheme.outlineVariant.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          CurrencyFormatter.format(balance.abs()),
                          style: TextStyle(
                            fontFamily: MyString.poppinsBold,
                            fontWeight: FontWeight.w700,
                            fontSize: 16.sp,
                            color: color,
                          ),
                        ),
                        Text(
                          isSurplus ? 'Surplus' : 'Deficit',
                          style: TextStyle(fontSize: 11.sp, color: color),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
