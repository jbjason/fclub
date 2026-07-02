import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/feature/locker/presentation/provider/locker_provider.dart';
import 'package:fclub/feature/locker/presentation/widgets/locker_expense_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Reached by tapping the Add Expense FAB on [LockerScreen]. Saving returns
/// to the dashboard with stats already refreshed via [LockerProvider].
class LockerAddExpenseScreen extends StatelessWidget {
  const LockerAddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('add_expense'.tr())),
      body: LockerExpenseForm(
        submitLabel: 'save'.tr(),
        onSubmit: ({required title, required amount, required date, note}) async {
          await context.read<LockerProvider>().addExpense(
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
