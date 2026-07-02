import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/feature/club/data/model/payment_entry.dart';
import 'package:fclub/feature/club/presentation/provider/club_provider.dart';
import 'package:fclub/feature/club/presentation/widgets/club_entry_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Step 3 of the required flow: reached by tapping an existing history item.
/// Same form as Add, prefilled, plus an optional Delete action.
class ClubEditEntryScreen extends StatelessWidget {
  const ClubEditEntryScreen({super.key, required this.entry});

  final PaymentEntry entry;

  Future<void> _confirmDelete(BuildContext context) async {
    final clubProvider = context.read<ClubProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('club_delete_confirm'.tr()),
        content: Text('club_delete_warning'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await clubProvider.deleteEntry(entry.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('club_edit_entry'.tr()),
        actions: [
          IconButton(
            tooltip: 'Delete entry',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ClubEntryForm(
        initialEntry: entry,
        submitLabel: 'club_update_entry'.tr(),
        onSubmit: ({
          required contactId,
          required month,
          required amount,
          required status,
          required date,
          note,
        }) async {
          await context.read<ClubProvider>().updateEntry(
                id: entry.id,
                contactId: contactId,
                month: month,
                amount: amount,
                status: status,
                date: date,
                note: note,
              );
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }
}
