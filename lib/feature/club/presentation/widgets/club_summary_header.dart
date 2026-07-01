import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/club/presentation/widgets/club_card_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Finance-style stat row. Reflects whatever scope the caller passes in —
/// e.g. the currently filtered entries, or a single month's entries.
class ClubSummaryHeader extends StatelessWidget {
  const ClubSummaryHeader({
    super.key,
    required this.collected,
    required this.totalDue,
    required this.totalAdvance,
  });

  final double collected;
  final double totalDue;
  final double totalAdvance;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          label: 'Collected',
          amount: collected,
          icon: Icons.savings_rounded,
          color: MyColor.success,
        ),
        SizedBox(width: 10.w),
        _StatCard(
          label: 'Due',
          amount: totalDue,
          icon: Icons.error_rounded,
          color: MyColor.error,
        ),
        SizedBox(width: 10.w),
        _StatCard(
          label: 'Advance',
          amount: totalAdvance,
          icon: Icons.upcoming_rounded,
          color: MyColor.warning,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutBack,
        builder: (context, value, child) =>
            Transform.scale(scale: value, child: child),
        child: ClubCardShell(
          accent: color,
          borderRadius: BorderRadius.circular(16.r),
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClubCardIcon(icon: icon, accent: color, size: 28),
              SizedBox(height: 8.h),
              Text(
                CurrencyFormatter.format(amount),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontFamily: MyString.poppinsBold,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontFamily: MyString.rubikRegular,
                  fontSize: 10.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
