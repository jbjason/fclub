import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/list_extensions.dart';
import 'package:fclub/feature/tour/data/models/tour_expense.dart';
import 'package:fclub/feature/tour/data/models/tour_participant.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_details/tour_empty_state.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_details/tour_expense_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourExpensesTab extends StatelessWidget {
  const TourExpensesTab({
    super.key,
    required this.expenses,
    required this.members,
    this.onDelete,
  });

  final List<TourExpense> expenses;
  final List<TourParticipant> members;
  final void Function(String expenseId)? onDelete;

  Map<String, List<TourExpense>> get _grouped {
    final map = <String, List<TourExpense>>{};
    for (final expense in expenses) {
      final key = DateFormat('MMM d, yyyy').format(expense.createdAt);
      map.putIfAbsent(key, () => []).add(expense);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return TourEmptyState(
        icon: Icons.receipt_long_rounded,
        message: 'tour_no_expenses'.tr(),
      );
    }

    final grouped = _grouped;
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: grouped.entries.expand((entry) {
        return [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              entry.key,
              style: TextStyle(
                fontFamily: MyString.poppinsMedium,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
                color: colorScheme.outline,
              ),
            ),
          ),
          ...entry.value.map((expense) {
            final payer = expense.paidByAllMembers
                ? null
                : members.firstWhereOrNull(
                    (member) => member.id == expense.paidByMemberId,
                  );
            return TourExpenseTile(
              expense: expense,
              payer: payer,
              totalMemberCount: members.length,
              onDelete: onDelete == null ? null : () => onDelete!(expense.id),
            );
          }),
        ];
      }).toList(),
    );
  }
}
