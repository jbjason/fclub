import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/tour/data/expense_category.dart';
import 'package:fclub/feature/tour/data/model/tour_session.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_detail_section.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_member_avatar.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_summary_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

abstract class TourHistoryDetailSheet {
  static void show(BuildContext context, TourSession session) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TourHistoryDetailContent(session: session),
    );
  }
}

class TourHistoryDetailContent extends StatelessWidget {
  const TourHistoryDetailContent({super.key, required this.session});
  final TourSession session;

  @override
  Widget build(BuildContext context) {
    final spent = session.totalSpent;
    final budget = session.decidedBudget;
    final collected = session.totalCollected;
    final progress =
        budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final isOver = spent > budget;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: ListView(
          controller: controller,
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 16.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                    color: MyColor.gray200,
                    borderRadius: BorderRadius.circular(2.r)),
              ),
            ),

            // Title row
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: MyColor.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.card_travel_rounded,
                      color: MyColor.primary, size: 22.r),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.tourName,
                        style: TextStyle(
                            fontFamily: MyString.poppinsBold,
                            fontSize: 16.sp,
                            color: MyColor.onSurface),
                      ),
                      Text(
                        DateFormat('EEEE, d MMMM y')
                            .format(session.createdAt),
                        style: TextStyle(
                            fontFamily: MyString.rubikRegular,
                            fontSize: 11.sp,
                            color: MyColor.gray400),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Budget summary
            TourDetailSection(
              title: 'Budget Summary',
              child: Column(
                children: [
                  TourSummaryRow(
                      label: 'Decided budget',
                      value: CurrencyFormatter.format(budget)),
                  TourSummaryRow(
                      label: 'Collected',
                      value: CurrencyFormatter.format(collected),
                      valueColor: MyColor.success),
                  TourSummaryRow(
                      label: 'Total spent',
                      value: CurrencyFormatter.format(spent),
                      valueColor:
                          isOver ? MyColor.error : MyColor.primary),
                  SizedBox(height: 10.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8.h,
                      backgroundColor: MyColor.gray100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          isOver ? MyColor.error : MyColor.success),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Members
            TourDetailSection(
              title: 'Members (${session.members.length})',
              child: Column(
                children: session.members.map((m) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        TourMemberAvatar(
                          name: m.name,
                          colorIndex: m.avatarColorIndex,
                          radius: 17.r,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(m.name,
                              style: TextStyle(
                                  fontFamily: MyString.rubikRegular,
                                  fontSize: 13.sp,
                                  color: MyColor.onSurface)),
                        ),
                        Text(
                          CurrencyFormatter.format(m.paidToManager),
                          style: TextStyle(
                              fontFamily: MyString.poppinsBold,
                              fontSize: 12.sp,
                              color: MyColor.primary),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 16.h),

            // Expenses
            TourDetailSection(
              title: 'Expenses (${session.expenses.length})',
              child: Column(
                children: session.expenses.map((e) {
                  final cat = ExpenseCategory
                      .values[e.categoryIndex % ExpenseCategory.values.length];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Icon(cat.icon, size: 16.r, color: cat.color),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(e.title,
                              style: TextStyle(
                                  fontFamily: MyString.rubikRegular,
                                  fontSize: 13.sp,
                                  color: MyColor.onSurface)),
                        ),
                        Text(
                          CurrencyFormatter.format(e.amount),
                          style: TextStyle(
                              fontFamily: MyString.poppinsBold,
                              fontSize: 12.sp,
                              color: MyColor.error),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
