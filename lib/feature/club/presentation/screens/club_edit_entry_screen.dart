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
        title: const Text('Delete this entry?'),
        content: const Text('This payment record will be permanently removed.'),
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
      await clubProvider.deleteEntry(entry.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Entry'),
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
        submitLabel: 'Update Entry',
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
