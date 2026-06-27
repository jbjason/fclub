import 'package:fclub/feature/club/presentation/provider/club_provider.dart';
import 'package:fclub/feature/club/presentation/widgets/club_entry_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Step 2 of the required flow: reached by tapping the Add button on
/// [ClubHistoryScreen]. Saving returns to History with the list already
/// refreshed via [ClubProvider]'s reactive state.
class ClubAddEntryScreen extends StatelessWidget {
  const ClubAddEntryScreen({super.key, this.initialMonth});

  /// Pre-selects a month when launched from a specific month's detail view.
  final DateTime? initialMonth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Entry')),
      body: ClubEntryForm(
        initialMonth: initialMonth,
        submitLabel: 'Save Entry',
        onSubmit: ({
          required contactId,
          required month,
          required amount,
          required status,
          required date,
          note,
        }) async {
          await context.read<ClubProvider>().addEntry(
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
