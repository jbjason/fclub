import 'package:fclub/feature/locker/data/model/locker_expense.dart';
import 'package:fclub/feature/locker/presentation/provider/locker_provider.dart';
import 'package:fclub/feature/locker/presentation/screens/locker_add_expense_screen.dart';
import 'package:fclub/feature/locker/presentation/screens/locker_edit_expense_screen.dart';
import 'package:fclub/feature/locker/presentation/widgets/locker_balance_card.dart';
import 'package:fclub/feature/locker/presentation/widgets/locker_edit_balance_dialog.dart';
import 'package:fclub/feature/locker/presentation/widgets/locker_empty_state.dart';
import 'package:fclub/feature/locker/presentation/widgets/locker_expense_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// Locker management dashboard: an admin-editable base balance ("total
/// collected from members"), expenses deducted from it, and the resulting
/// statistics/cash-on-hand.
class LockerScreen extends StatefulWidget {
  const LockerScreen({super.key});

  @override
  State<LockerScreen> createState() => _LockerScreenState();
}

class _LockerScreenState extends State<LockerScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final lockerProvider = context.read<LockerProvider>();
      await lockerProvider.seedDemoData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openAddExpense() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const LockerAddExpenseScreen()),
    );
  }

  Future<void> _openEditExpense(LockerExpense expense) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => LockerEditExpenseScreen(expense: expense)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lockerProvider = context.watch<LockerProvider>();
    final expenses = lockerProvider.expenses;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Locker')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: LockerBalanceCard(
                currentCash: lockerProvider.currentCash,
                collected: lockerProvider.baseBalance,
                spent: lockerProvider.totalExpenses,
                onEditBalance: () => showLockerEditBalanceDialog(context, lockerProvider),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Expense History',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            Expanded(
              child: expenses.isEmpty
                  ? const LockerEmptyState(
                      message: 'No expenses recorded yet.\nTap "Add Expense" to log the first one.',
                    )
                  : Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          return LockerExpenseTile(
                            expense: expense,
                            onTap: () => _openEditExpense(expense),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddExpense,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense'),
      ),
    );
  }
}
