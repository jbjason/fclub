import 'package:fclub/core/services/contacts/app_contact.dart';
import 'package:fclub/core/services/contacts/global_contacts_provider.dart';
import 'package:fclub/feature/club/data/model/payment_entry.dart';
import 'package:fclub/feature/club/data/model/payment_status.dart';
import 'package:fclub/feature/club/presentation/provider/club_provider.dart';
import 'package:fclub/feature/club/presentation/screens/club_add_entry_screen.dart';
import 'package:fclub/feature/club/presentation/screens/club_edit_entry_screen.dart';
import 'package:fclub/feature/club/presentation/widgets/club_empty_state.dart';
import 'package:fclub/feature/club/presentation/widgets/club_filter_bar.dart';
import 'package:fclub/feature/club/presentation/widgets/club_history_tile.dart';
import 'package:fclub/feature/club/presentation/widgets/club_summary_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Drill-down from [ClubMonthlyOverviewScreen] — that one month's stats and
/// member-by-member entries. Tapping a row still opens the normal Edit
/// screen, so editing/deleting behaves identically to the main History list.
class ClubMonthDetailScreen extends StatefulWidget {
  const ClubMonthDetailScreen({super.key, required this.month});

  final DateTime month;

  @override
  State<ClubMonthDetailScreen> createState() => _ClubMonthDetailScreenState();
}

class _ClubMonthDetailScreenState extends State<ClubMonthDetailScreen> {
  final _scrollController = ScrollController();

  String _searchQuery = '';
  PaymentStatus? _selectedStatus;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openAddEntry() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ClubAddEntryScreen(initialMonth: widget.month),
      ),
    );
  }

  Future<void> _openEditEntry(PaymentEntry entry) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => ClubEditEntryScreen(entry: entry)),
    );
  }

  List<PaymentEntry> _applyFilters(
    List<PaymentEntry> monthEntries,
    Map<String, AppContact> contactsById,
  ) {
    final query = _searchQuery.trim().toLowerCase();
    return monthEntries.where((entry) {
      final contact = contactsById[entry.contactId];
      final matchesSearch =
          query.isEmpty || (contact?.name.toLowerCase().contains(query) ?? false);
      final matchesStatus = _selectedStatus == null || entry.status == _selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<ClubProvider>().entries;
    final contacts = context.watch<GlobalContactsProvider>().contacts;
    final contactsById = {for (final contact in contacts) contact.id: contact};

    final monthEntries = entries.where((e) => e.month == widget.month).toList();
    final filtered = _applyFilters(monthEntries, contactsById);

    final collected = filtered
        .where((e) => e.status == PaymentStatus.paid)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final totalDue = filtered
        .where((e) => e.status == PaymentStatus.due)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final totalAdvance = filtered
        .where((e) => e.status == PaymentStatus.advance)
        .fold<double>(0, (sum, e) => sum + e.amount);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text(DateFormat('MMMM yyyy').format(widget.month))),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: ClubSummaryHeader(
                collected: collected,
                totalDue: totalDue,
                totalAdvance: totalAdvance,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: ClubFilterBar(
                onSearchChanged: (value) => setState(() => _searchQuery = value),
                showMonthFilter: false,
                selectedStatus: _selectedStatus,
                onStatusChanged: (value) => setState(() => _selectedStatus = value),
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: filtered.isEmpty
                  ? ClubEmptyState(
                      message: monthEntries.isEmpty
                          ? 'No records for this month yet.'
                          : 'No entries match your filters.',
                    )
                  : Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final entry = filtered[index];
                          return ClubHistoryTile(
                            entry: entry,
                            contact: contactsById[entry.contactId],
                            onTap: () => _openEditEntry(entry),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddEntry,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Entry'),
      ),
    );
  }
}
