import 'package:fclub/config/router/app_router.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/home/presentation/widgets/home_stat_shell.dart';
import 'package:fclub/feature/locker/presentation/provider/locker_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// A dashboard highlight card showing the locker's live cash position:
/// available cash, total collected, and total spent.
///
/// Data source: [LockerProvider] — watched reactively.
///
/// The "Available" figure is colour-coded:
///   • Green  → ≥ 20 % of base balance remaining  (healthy)
///   • Rose   → < 20 % remaining                  (low cash warning)
///
/// Tapping the card pushes [AppRouteName.locker].
class HomeLockerStatCard extends StatelessWidget {
  const HomeLockerStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    final locker = context.watch<LockerProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    // ── Cash health colour ──────────────────────────────────────────────────
    final isLow = locker.baseBalance > 0 &&
        locker.currentCash / locker.baseBalance < 0.20;
    final availableColor = isLow ? MyColor.tertiary : MyColor.success;

    // ── Expense count subtitle ──────────────────────────────────────────────
    final expenseCount = locker.expenses.length;
    final subtitle = expenseCount == 0
        ? 'No expenses recorded'
        : '$expenseCount expense${expenseCount == 1 ? '' : 's'} recorded';

    return HomeStatCardShell(
      accent: MyColor.secondary,
      isDark: isDark,
      onTap: () => Navigator.pushNamed(context, AppRouteName.locker),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ─────────────────────────────────────────────────────
          Row(
            children: [
              const HomeStatCardIcon(
                icon: Icons.lock_outline_rounded,
                accent: MyColor.secondary,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Locker',
                      style: TextStyle(
                        fontFamily: MyString.poppinsMedium,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    // Status badge — changes colour when cash is low
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: availableColor.withValues(
                            alpha: isDark ? 0.20 : 0.10),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isLow)
                            Padding(
                              padding: EdgeInsets.only(right: 4.w),
                              child: Icon(
                                Icons.warning_amber_rounded,
                                size: 10.r,
                                color: availableColor,
                              ),
                            ),
                          Text(
                            isLow ? 'Low cash' : subtitle,
                            style: TextStyle(
                              fontFamily: MyString.rubikRegular,
                              fontSize: 10.sp,
                              color: availableColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const HomeStatCardArrow(accent: MyColor.secondary),
            ],
          ),
          SizedBox(height: 14.h),
          // ── Divider ────────────────────────────────────────────────────────
          Divider(
            color: MyColor.secondary.withValues(alpha: 0.15),
            height: 1,
            thickness: 1,
          ),
          SizedBox(height: 12.h),
          // ── Stats ──────────────────────────────────────────────────────────
          HomeStatValueRow(
            accent: MyColor.secondary,
            items: [
              HomeStatValueItem(
                label: 'Available',
                value: CurrencyFormatter.format(locker.currentCash),
                valueColor: availableColor,
              ),
              HomeStatValueItem(
                label: 'Collected',
                value: CurrencyFormatter.format(locker.baseBalance),
                valueColor: MyColor.success,
              ),
              HomeStatValueItem(
                label: 'Spent',
                value: CurrencyFormatter.format(locker.totalExpenses),
                valueColor: MyColor.tertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
