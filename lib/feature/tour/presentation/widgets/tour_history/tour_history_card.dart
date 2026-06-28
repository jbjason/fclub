import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/tour/data/model/tour_session.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_history/tour_history_detail_sheet.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_history/tour_info_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class TourHistoryCard extends StatelessWidget {
  const TourHistoryCard({super.key, required this.session, required this.onDelete});
  final TourSession session;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spent = session.totalSpent;
    final budget = session.decidedBudget;
    final progress =
        budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final isOver = spent > budget;
    final progressColor = isOver ? MyColor.error : MyColor.success;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: () => TourHistoryDetailSheet.show(context, session),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ─────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: MyColor.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.card_travel_rounded,
                          color: MyColor.primary, size: 18.r),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.tourName,
                            style: TextStyle(
                              fontFamily: MyString.poppinsBold,
                              fontSize: 14.sp,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            DateFormat('d MMM y')
                                .format(session.createdAt),
                            style: TextStyle(
                              fontFamily: MyString.rubikRegular,
                              fontSize: 11.sp,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(Icons.delete_outline_rounded,
                          color: colorScheme.onSurfaceVariant, size: 20.r),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // ── Spending bar ────────────────────────────────
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Spent',
                        style: TextStyle(
                            fontFamily: MyString.rubikRegular,
                            fontSize: 11.sp,
                            color: colorScheme.onSurfaceVariant)),
                    Text(
                      '${CurrencyFormatter.format(spent)} / ${CurrencyFormatter.format(budget)}',
                      style: TextStyle(
                        fontFamily: MyString.poppinsBold,
                        fontSize: 11.sp,
                        color: isOver
                            ? MyColor.error
                            : MyColor.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6.h,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        progressColor),
                  ),
                ),
                SizedBox(height: 12.h),

                // ── Chips ───────────────────────────────────────
                Row(
                  children: [
                    TourInfoChip(
                      icon: Icons.people_rounded,
                      label:
                          '${session.members.length} members',
                      color: MyColor.primary,
                    ),
                    SizedBox(width: 8.w),
                    TourInfoChip(
                      icon: Icons.receipt_long_rounded,
                      label:
                          '${session.expenses.length} expenses',
                      color: MyColor.secondary,
                    ),
                    SizedBox(width: 8.w),
                    TourInfoChip(
                      icon: Icons.payments_rounded,
                      label:
                          '${session.extraPayments.length} payments',
                      color: MyColor.tertiary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
