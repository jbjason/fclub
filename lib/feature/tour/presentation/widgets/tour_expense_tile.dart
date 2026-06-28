import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/tour/data/expense_category.dart';
import 'package:fclub/feature/tour/data/model/tour_expense_model.dart';
import 'package:fclub/feature/tour/data/model/tour_member_model.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourExpenseTile extends StatelessWidget {
  const TourExpenseTile({
    super.key,
    required this.expense,
    required this.payer,
    required this.totalMemberCount,
  });

  final TourExpenseModel expense;
  final TourMemberModel? payer;
  final int totalMemberCount;

  String get _beneficiaryLabel {
    final count = expense.beneficiaryMemberIds.isEmpty
        ? totalMemberCount
        : expense.beneficiaryMemberIds.length;
    if (count >= totalMemberCount) return 'All';
    return '$count people';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final category = ExpenseCategory.values[expense.categoryIndex];
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          TourMemberAvatar(
            name: payer?.name ?? '?',
            colorIndex: payer?.avatarColorIndex ?? 0,
            radius: 18.r,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: MyString.poppinsMedium,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(category.icon, size: 14.r, color: category.color),
                    SizedBox(width: 4.w),
                    Text(
                      'Paid by ${payer?.name ?? 'Unknown'}',
                      style: TextStyle(
                        fontFamily: MyString.poppinsRegular,
                        fontSize: 11.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(expense.amount),
                style: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  _beneficiaryLabel,
                  style: TextStyle(
                    fontFamily: MyString.poppinsRegular,
                    fontSize: 10.sp,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
