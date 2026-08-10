import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/kurbani/presentation/provider/kurbani_event_provider.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/management/kurbani_empty_state.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/management/expenses/kurbani_expense_tile.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_section_header.dart';
import 'package:flutter/material.dart';

class KurbaniExpenseTab extends StatelessWidget {
  const KurbaniExpenseTab({
    super.key,
    required this.provider,
    required this.onDelete,
  });

  final KurbaniEventProvider provider;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    final expenses = provider.expenses;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      children: [
        KurbaniSectionHeader(
          title: 'kurbani_expense_ledger'.tr(),
          subtitle: 'kurbani_expense_total'.tr(
            namedArgs: {
              'count': '${expenses.length}',
              'amount': CurrencyFormatter.format(provider.summary.totalSpent),
            },
          ),
          icon: Icons.receipt_long_rounded,
          accent: KurbaniPalette.cyan,
        ),
        const SizedBox(height: 12),
        if (expenses.isEmpty)
          KurbaniEmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'kurbani_no_expenses_title'.tr(),
            message: provider.canEdit
                ? 'kurbani_no_expenses_admin'.tr()
                : 'kurbani_no_expenses_member'.tr(),
          )
        else
          ...expenses.map(
            (expense) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: KurbaniExpenseTile(
                expense: expense,
                participants: provider.participants,
                onDelete: provider.canEdit ? () => onDelete(expense.id) : null,
              ),
            ),
          ),
      ],
    );
  }
}
