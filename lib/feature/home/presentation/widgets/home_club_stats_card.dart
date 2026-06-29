import 'package:fclub/config/router/app_router.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/club/data/model/payment_status.dart';
import 'package:fclub/feature/club/presentation/provider/club_provider.dart';
import 'package:fclub/feature/home/presentation/widgets/home_stat_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// A dashboard highlight card showing the **current month's** club payment
/// breakdown (collected, due, advance).
///
/// Data source: [ClubProvider] — watched reactively so the card updates
/// whenever an entry is added, edited, or deleted elsewhere in the app.
///
/// Tapping the card pushes [AppRouteName.club] (the monthly overview screen).
class HomeClubStatsCard extends StatelessWidget {
  const HomeClubStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final clubProvider = context.watch<ClubProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    // ── Compute current-month stats ─────────────────────────────────────────
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final monthLabel = DateFormat('MMMM yyyy').format(currentMonth);

    final monthEntries =
        clubProvider.entries.where((e) => e.month == currentMonth).toList();

    final collected = monthEntries
        .where((e) => e.status == PaymentStatus.paid)
        .fold<double>(0, (s, e) => s + e.amount);
    final due = monthEntries
        .where((e) => e.status == PaymentStatus.due)
        .fold<double>(0, (s, e) => s + e.amount);
    final advance = monthEntries
        .where((e) => e.status == PaymentStatus.advance)
        .fold<double>(0, (s, e) => s + e.amount);

    return HomeStatCardShell(
      accent: MyColor.primary,
      isDark: isDark,
      onTap: () => Navigator.pushNamed(context, AppRouteName.club),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ─────────────────────────────────────────────────────
          Row(
            children: [
              const HomeStatCardIcon(
                icon: Icons.savings_rounded,
                accent: MyColor.primary,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fundora Club',
                      style: TextStyle(
                        fontFamily: MyString.poppinsMedium,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    // Month badge
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: MyColor.primary.withValues(
                            alpha: isDark ? 0.20 : 0.10),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        monthLabel,
                        style: TextStyle(
                          fontFamily: MyString.rubikRegular,
                          fontSize: 10.sp,
                          color: MyColor.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const HomeStatCardArrow(accent: MyColor.primary),
            ],
          ),
          SizedBox(height: 14.h),
          // ── Divider ────────────────────────────────────────────────────────
          Divider(
            color: MyColor.primary.withValues(alpha: 0.15),
            height: 1,
            thickness: 1,
          ),
          SizedBox(height: 12.h),
          // ── Stats or empty hint ────────────────────────────────────────────
          if (monthEntries.isEmpty)
            HomeStatEmptyHint(
              message: 'No entries recorded this month.',
              accent: MyColor.primary,
            )
          else
            HomeStatValueRow(
              accent: MyColor.primary,
              items: [
                HomeStatValueItem(
                  label: 'Collected',
                  value: CurrencyFormatter.format(collected),
                  valueColor: MyColor.success,
                ),
                HomeStatValueItem(
                  label: 'Due',
                  value: CurrencyFormatter.format(due),
                  valueColor: MyColor.tertiary,
                ),
                HomeStatValueItem(
                  label: 'Advance',
                  value: CurrencyFormatter.format(advance),
                  valueColor: MyColor.secondary,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
