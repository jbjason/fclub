import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/list_extensions.dart';
import 'package:fclub/feature/tour/data/model/tour_expense_model.dart';
import 'package:fclub/feature/tour/data/model/tour_member_model.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_cost_manage/tour_empty_state.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_cost_manage/tour_expense_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class TourExpensesTab extends StatelessWidget {
  const TourExpensesTab({super.key, required this.expenses, required this.members});

  final List<TourExpenseModel> expenses;
  final List<TourMemberModel> members;

  Map<String, List<TourExpenseModel>> get _grouped {
    final map = <String, List<TourExpenseModel>>{};
    for (final expense in expenses) {
      final key = DateFormat('MMM d, yyyy').format(expense.timestamp);
      map.putIfAbsent(key, () => []).add(expense);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const TourEmptyState(
        icon: Icons.receipt_long_rounded,
        message: 'No expenses yet.',
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
            final payer = members.firstWhereOrNull(
              (member) => member.id == expense.paidByMemberId,
            );
            return TourExpenseTile(
              expense: expense,
              payer: payer,
              totalMemberCount: members.length,
            );
          }),
        ];
      }).toList(),
    );
  }
}
