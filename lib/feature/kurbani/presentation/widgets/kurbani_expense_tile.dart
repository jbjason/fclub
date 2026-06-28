import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_expense_model.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_member_model.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/kurbani_member_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class KurbaniExpenseTile extends StatelessWidget {
  const KurbaniExpenseTile({
    super.key,
    required this.expense,
    required this.members,
    this.onDelete,
  });

  final KurbaniExpenseModel expense;
  final List<KurbaniMemberModel> members;
  final VoidCallback? onDelete;

  static final _dateFormat = DateFormat('dd MMM, hh:mm a');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final payer = members.firstWhere(
      (m) => m.id == expense.paidByMemberId,
      orElse: () => KurbaniMemberModel(
          id: '', name: 'Unknown', avatarColorIndex: 0, contribution: 0),
    );
    final gradients = kurbaniAvatarGradients[
        payer.avatarColorIndex % kurbaniAvatarGradients.length];

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 22.r),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            // Mini avatar
            Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradients,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 16.r,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Title + payer + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: TextStyle(
                      fontFamily: MyString.poppinsBold,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Text(
                        'Paid by ${payer.name}',
                        style: TextStyle(
                          fontFamily: MyString.rubikRegular,
                          fontSize: 10.sp,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (expense.note != null) ...[
                        Text(
                          ' · ${expense.note}',
                          style: TextStyle(
                            fontFamily: MyString.rubikRegular,
                            fontSize: 10.sp,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _dateFormat.format(expense.timestamp),
                    style: TextStyle(
                      fontFamily: MyString.rubikRegular,
                      fontSize: 9.sp,
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            // Amount
            Text(
              CurrencyFormatter.format(expense.amount),
              style: TextStyle(
                fontFamily: MyString.poppinsBold,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6D28D9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
