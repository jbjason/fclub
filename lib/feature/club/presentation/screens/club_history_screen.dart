import 'package:fclub/core/services/contacts/app_contact.dart';
import 'package:fclub/core/services/contacts/global_contacts_provider.dart';
import 'package:fclub/feature/club/data/model/payment_entry.dart';
import 'package:fclub/feature/club/data/model/payment_status.dart';
import 'package:fclub/feature/club/presentation/provider/club_provider.dart';
import 'package:fclub/feature/club/presentation/screens/club_add_entry_screen.dart';
import 'package:fclub/feature/club/presentation/screens/club_edit_entry_screen.dart';
import 'package:fclub/feature/club/presentation/screens/club_monthly_overview_screen.dart';
import 'package:fclub/feature/club/presentation/widgets/club_empty_state.dart';
import 'package:fclub/feature/club/presentation/widgets/club_filter_bar.dart';
import 'package:fclub/feature/club/presentation/widgets/club_history_tile.dart';
import 'package:fclub/feature/club/presentation/widgets/club_summary_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// Step 1 of the required flow — the default landing screen for the club
/// feature. Lists every payment record with search/month/status filters;
/// the Add FAB and tapping a row are the only ways in/out to Add/Edit.
class ClubHistoryScreen extends StatefulWidget {
  const ClubHistoryScreen({super.key});

  @override
  State<ClubHistoryScreen> createState() => _ClubHistoryScreenState();
}

class _ClubHistoryScreenState extends State<ClubHistoryScreen> {
  final _scrollController = ScrollController();

  String _searchQuery = '';
  DateTime? _selectedMonth;
  PaymentStatus? _selectedStatus;

  @override
  void initState() {
    super.initState(); 
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final globalContacts = context.read<GlobalContactsProvider>();
      final clubProvider = context.read<ClubProvider>();
      await globalContacts.seedDemoData();
      await clubProvider.seedDemoData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openAddEntry() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const ClubAddEntryScreen()),
    );
  }

  Future<void> _openEditEntry(PaymentEntry entry) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => ClubEditEntryScreen(entry: entry)),
    );
  }

  List<PaymentEntry> _applyFilters(
    List<PaymentEntry> entries,
    Map<String, AppContact> contactsById,
  ) {
    final query = _searchQuery.trim().toLowerCase();
    return entries.where((entry) {
      final contact = contactsById[entry.contactId];
      final matchesSearch =
          query.isEmpty || (contact?.name.toLowerCase().contains(query) ?? false);
      final matchesMonth = _selectedMonth == null || entry.month == _selectedMonth;
      final matchesStatus = _selectedStatus == null || entry.status == _selectedStatus;
      return matchesSearch && matchesMonth && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<ClubProvider>().entries;
    final contacts = context.watch<GlobalContactsProvider>().contacts;
    final contactsById = {for (final contact in contacts) contact.id: contact};

    final filtered = _applyFilters(entries, contactsById);
    final availableMonths = entries.map((e) => e.month).toSet().toList()
      ..sort((a, b) => b.compareTo(a));

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
      appBar: AppBar(
        title: const Text('Fundora Club'),
        actions: [
          IconButton(
            tooltip: 'Monthly overview',
            icon: const Icon(Icons.calendar_view_month_rounded),
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(builder: (_) => const ClubMonthlyOverviewScreen()),
            ),
          ),
        ],
      ),
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
                availableMonths: availableMonths,
                selectedMonth: _selectedMonth,
                onMonthChanged: (value) => setState(() => _selectedMonth = value),
                selectedStatus: _selectedStatus,
                onStatusChanged: (value) => setState(() => _selectedStatus = value),
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: filtered.isEmpty
                  ? ClubEmptyState(
                      message: entries.isEmpty
                          ? 'No payment records yet.\nTap "Add Entry" to record the first one.'
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
