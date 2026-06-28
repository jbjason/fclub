import 'package:fclub/core/constants/my_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourBudgetProgressBar extends StatelessWidget {
  const TourBudgetProgressBar({
    super.key,
    required this.progress,
    required this.isOverBudget,
  });

  /// 0.0 - 1.0
  final double progress;
  final bool isOverBudget;

  @override
  Widget build(BuildContext context) {
    final color = isOverBudget ? MyColor.error : MyColor.white;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0, 1)),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Container(
          height: 10.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: MyColor.white.withValues(alpha: 0.25),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.55),
                blurRadius: 8.r,
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
