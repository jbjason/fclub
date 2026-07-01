import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/locker/data/model/locker_expense.dart';
import 'package:fclub/feature/locker/presentation/widgets/locker_card_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

/// A single row in the locker's expense history. Tapping it opens the edit
/// screen.
class LockerExpenseTile extends StatelessWidget {
  const LockerExpenseTile({super.key, required this.expense, required this.onTap});

  final LockerExpense expense;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LockerCardShell(
      accent: MyColor.error,
      onTap: onTap,
      margin: EdgeInsets.only(bottom: 10.h),
      child: Row(
            children: [
              LockerCardIcon(
                icon: Icons.arrow_upward_rounded,
                accent: MyColor.error,
                size: 38,
              ),
              SizedBox(width: 12.w),
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
                    SizedBox(height: 2.h),
                    Text(
                      DateFormat('d MMM yyyy').format(expense.date),
                      style: TextStyle(
                        fontFamily: MyString.rubikRegular,
                        fontSize: 11.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (expense.note != null && expense.note!.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        expense.note!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: MyString.rubikRegular,
                          fontSize: 11.sp,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '-${CurrencyFormatter.format(expense.amount)}',
                style: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                  color: MyColor.error,
                ),
              ),
            ],
          ),
    );
  }
}
