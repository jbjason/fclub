import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_expense.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_participant.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_card_shell.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:flutter/material.dart';

class KurbaniExpenseTile extends StatelessWidget {
  const KurbaniExpenseTile({
    super.key,
    required this.expense,
    required this.participants,
    this.onDelete,
  });

  final KurbaniExpense expense;
  final List<KurbaniParticipant> participants;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final payer = _payerName();
    final card = KurbaniCardShell(
      accent: KurbaniPalette.cyan,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [KurbaniPalette.cyan, KurbaniPalette.violet],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.receipt_long_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: MyString.poppinsBold,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'kurbani_paid_by'.tr(namedArgs: {'name': payer}),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontFamily: MyString.rubikRegular,
                    fontSize: 9.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat.yMMMd(
                    context.locale.toString(),
                  ).format(expense.createdAt),
                  style: TextStyle(
                    color: colors.outline,
                    fontFamily: MyString.rubikRegular,
                    fontSize: 8.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            CurrencyFormatter.format(expense.amount),
            style: const TextStyle(
              color: KurbaniPalette.cyan,
              fontFamily: MyString.poppinsBold,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
    if (onDelete == null) return card;
    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('kurbani_delete_expense_title'.tr()),
          content: Text('kurbani_delete_expense_message'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('cancel'.tr()),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: KurbaniPalette.rose,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text('delete'.tr()),
            ),
          ],
        ),
      ),
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: KurbaniPalette.rose,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: card,
    );
  }

  String _payerName() {
    for (final participant in participants) {
      if (participant.id == expense.paidByMemberId) return participant.username;
    }
    return expense.paidByMemberId;
  }
}
