import 'package:fclub/feature/club/presentation/provider/club_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Month picker for [ClubEntryForm], offering every month from the club's
/// start date through a few months ahead (to allow advance payments).
class ClubMonthDropdown extends StatelessWidget {
  const ClubMonthDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  static List<DateTime> get _months {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month + 3, 1);
    final months = <DateTime>[];
    var month = ClubProvider.clubStartMonth;
    while (!month.isAfter(lastMonth)) {
      months.add(month);
      month = DateTime(month.year, month.month + 1, 1);
    }
    return months.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<DateTime>(
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Month'),
      items: _months.map((month) {
        return DropdownMenuItem(
          value: month,
          child: Text(DateFormat('MMMM yyyy').format(month)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Select a month' : null,
    );
  }
}
