import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/tour/data/models/tour_expense.dart';
import 'package:fclub/feature/tour/data/models/tour_participant.dart';
import 'package:fclub/feature/tour/presentation/extensions/tour_expense_category_extension.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_card_shell.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourExpenseTile extends StatelessWidget {
  const TourExpenseTile({
    super.key,
    required this.expense,
    required this.payer,
    required this.totalMemberCount,
    this.onDelete,
  });

  final TourExpense expense;
  final TourParticipant? payer;
  final int totalMemberCount;
  final VoidCallback? onDelete;

  String get _beneficiaryLabel {
    final count = expense.beneficiaryMemberIds.isEmpty
        ? totalMemberCount
        : expense.beneficiaryMemberIds.length;
    if (count >= totalMemberCount) return 'All';
    return '$count people';
  }

  String _payerLabel() =>
      expense.paidByAllMembers ? 'all'.tr() : payer?.name ?? 'Unknown';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final category = expense.category;
    return TourCardShell(
      accent: category.color,
      margin: EdgeInsets.only(bottom: 10.h),
      borderRadius: BorderRadius.circular(14.r),
      child: Row(
        children: [
          if (expense.paidByAllMembers)
            CircleAvatar(
              radius: 18.r,
              child: Icon(Icons.groups_rounded, size: 19.r),
            )
          else
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
                      'Paid by ${_payerLabel()}',
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
          if (onDelete != null)
            IconButton(
              tooltip: 'delete'.tr(),
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline_rounded,
                color: colorScheme.error,
                size: 19.r,
              ),
            ),
        ],
      ),
    );
  }
}
