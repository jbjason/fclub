import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/services/contacts/app_contact.dart';
import 'package:fclub/core/services/contacts/global_contacts_provider.dart';
import 'package:fclub/feature/club/data/model/payment_entry.dart';
import 'package:fclub/feature/club/data/model/payment_status.dart';
import 'package:fclub/feature/club/presentation/screens/club_details/club_add_entry_screen.dart';
import 'package:fclub/feature/club/presentation/screens/club_details/club_edit_entry_screen.dart';
import 'package:fclub/feature/club/presentation/provider/club_provider.dart';
import 'package:fclub/feature/club/presentation/screens/club_details/club_month_detail_screen.dart';
import 'package:fclub/feature/club/presentation/widgets/club_empty_state.dart';
import 'package:fclub/feature/club/presentation/widgets/club_filter_bar.dart';
import 'package:fclub/feature/club/presentation/widgets/club_history_tile.dart';
import 'package:fclub/feature/club/presentation/widgets/club_month_overview_tile.dart';
import 'package:fclub/feature/club/presentation/widgets/club_summary_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ClubMonthlyOverviewScreen extends StatefulWidget {
  const ClubMonthlyOverviewScreen({super.key});

  @override
  State<ClubMonthlyOverviewScreen> createState() =>
      _ClubMonthlyOverviewScreenState();
}

class _ClubMonthlyOverviewScreenState extends State<ClubMonthlyOverviewScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // History tab state
  final _historyScrollController = ScrollController();
  String _searchQuery = '';
  DateTime? _selectedMonth;
  PaymentStatus? _selectedStatus;

  // Overview tab state
  final _overviewScrollController = ScrollController();
  int? _selectedYear;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final globalContacts = context.read<GlobalContactsProvider>();
      final clubProvider = context.read<ClubProvider>();
      await globalContacts.loadContacts();
      await clubProvider.seedDemoData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _historyScrollController.dispose();
    _overviewScrollController.dispose();
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
          query.isEmpty ||
          (contact?.name.toLowerCase().contains(query) ?? false);
      final matchesMonth =
          _selectedMonth == null || entry.month == _selectedMonth;
      final matchesStatus =
          _selectedStatus == null || entry.status == _selectedStatus;
      return matchesSearch && matchesMonth && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final clubProvider = context.watch<ClubProvider>();
    final entries = clubProvider.entries;
    final contacts = clubProvider.clubMembers;
    final contactsById = {for (final c in contacts) c.id: c};

    // Overall unfiltered stats for the shared summary header
    final allCollected = entries
        .where((e) => e.status == PaymentStatus.paid)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final allDue = entries
        .where((e) => e.status == PaymentStatus.due)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final allAdvance = entries
        .where((e) => e.status == PaymentStatus.advance)
        .fold<double>(0, (sum, e) => sum + e.amount);

    // History tab data
    final filtered = _applyFilters(entries, contactsById);
    final availableMonths = entries.map((e) => e.month).toSet().toList()
      ..sort((a, b) => b.compareTo(a));

    // Overview tab data
    final months = entries.map((e) => e.month).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    final years = months.map((m) => m.year).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    final filteredMonths = _selectedYear == null
        ? months
        : months.where((m) => m.year == _selectedYear).toList();

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: Text('club_feature_title'.tr())),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
              child: ClubSummaryHeader(
                collected: allCollected,
                totalDue: allDue,
                totalAdvance: allAdvance,
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.outline,
              indicatorColor: colorScheme.primary,
              tabs: [
                Tab(
                  icon: const Icon(Icons.calendar_month_rounded, size: 18),
                  text: 'club_monthly_overview'.tr(),
                ),
                Tab(
                  icon: const Icon(Icons.receipt_long_rounded, size: 18),
                  text: 'history'.tr(),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(filteredMonths, months, years, entries),
                  _buildHistoryTab(
                    filtered,
                    entries,
                    availableMonths,
                    contactsById,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddEntry,
        icon: const Icon(Icons.add_rounded),
        label: Text('club_add_entry'.tr()),
      ),
    );
  }

  Widget _buildHistoryTab(
    List<PaymentEntry> filtered,
    List<PaymentEntry> entries,
    List<DateTime> availableMonths,
    Map<String, AppContact> contactsById,
  ) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
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
                      ? 'club_no_payments_yet'.tr()
                      : 'club_no_matches_filter'.tr(),
                )
              : Scrollbar(
                  controller: _historyScrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: _historyScrollController,
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
    );
  }

  Widget _buildOverviewTab(
    List<DateTime> filteredMonths,
    List<DateTime> months,
    List<int> years,
    List<PaymentEntry> entries,
  ) {
    return Column(
      children: [
        if (years.length > 1)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: Row(
              children: [
                ChoiceChip(
                  label: Text('all'.tr()),
                  selected: _selectedYear == null,
                  onSelected: (_) => setState(() => _selectedYear = null),
                ),
                ...years.map(
                  (year) => Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: ChoiceChip(
                      label: Text('$year'),
                      selected: _selectedYear == year,
                      onSelected: (selected) => setState(
                        () => _selectedYear = selected ? year : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: months.isEmpty
              ? ClubEmptyState(message: 'club_no_monthly_data'.tr())
              : filteredMonths.isEmpty
              ? ClubEmptyState(message: 'club_no_months_year'.tr())
              : Scrollbar(
                  controller: _overviewScrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: _overviewScrollController,
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
                    itemCount: filteredMonths.length,
                    itemBuilder: (context, index) {
                      final month = filteredMonths[index];
                      final monthEntries = entries
                          .where((e) => e.month == month)
                          .toList();
                      final collected = monthEntries
                          .where((e) => e.status == PaymentStatus.paid)
                          .fold<double>(0, (sum, e) => sum + e.amount);
                      final due = monthEntries
                          .where((e) => e.status == PaymentStatus.due)
                          .fold<double>(0, (sum, e) => sum + e.amount);
                      final advance = monthEntries
                          .where((e) => e.status == PaymentStatus.advance)
                          .fold<double>(0, (sum, e) => sum + e.amount);
                      final memberCount = monthEntries
                          .map((e) => e.contactId)
                          .toSet()
                          .length;
                      return ClubMonthOverviewTile(
                        month: month,
                        collected: collected,
                        due: due,
                        advance: advance,
                        memberCount: memberCount,
                        onTap: () => Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClubMonthDetailScreen(month: month),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
