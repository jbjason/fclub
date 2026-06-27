import 'package:fclub/feature/locker/data/model/locker_expense.dart';
import 'package:fclub/feature/locker/presentation/provider/locker_provider.dart';
import 'package:fclub/feature/locker/presentation/widgets/locker_expense_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Reached by tapping an existing row on [LockerScreen]. Same form as Add,
/// prefilled, plus an optional Delete action.
class LockerEditExpenseScreen extends StatelessWidget {
  const LockerEditExpenseScreen({super.key, required this.expense});

  final LockerExpense expense;

  Future<void> _confirmDelete(BuildContext context) async {
    final lockerProvider = context.read<LockerProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this expense?'),
        content: const Text('This record will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await lockerProvider.deleteExpense(expense.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Expense'),
        actions: [
          IconButton(
            tooltip: 'Delete expense',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: LockerExpenseForm(
        initialExpense: expense,
        submitLabel: 'Update Expense',
        onSubmit: ({required title, required amount, required date, note}) async {
          await context.read<LockerProvider>().updateExpense(
                id: expense.id,
                title: title,
                amount: amount,
                date: date,
                note: note,
              );
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }
}
