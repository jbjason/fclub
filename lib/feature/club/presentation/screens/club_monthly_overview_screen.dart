import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/services/contacts/global_contacts_provider.dart';
import 'package:fclub/feature/club/data/model/payment_status.dart';
import 'package:fclub/feature/club/presentation/screens/club_add_entry_screen.dart';
import 'package:fclub/feature/club/presentation/screens/club_history_screen.dart';
import 'package:fclub/feature/club/presentation/provider/club_provider.dart';
import 'package:fclub/feature/club/presentation/screens/club_month_detail_screen.dart';
import 'package:fclub/feature/club/presentation/widgets/club_empty_state.dart';
import 'package:fclub/feature/club/presentation/widgets/club_month_overview_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// Month-by-month view of club finances — "Jun 2025 (collected, due)",
/// "Jul 2025 (collected, due)", etc. Tapping a month opens
/// [ClubMonthDetailScreen] for that month's member-level breakdown.
class ClubMonthlyOverviewScreen extends StatefulWidget {
  const ClubMonthlyOverviewScreen({super.key});

  @override
  State<ClubMonthlyOverviewScreen> createState() =>
      _ClubMonthlyOverviewScreenState();
}

class _ClubMonthlyOverviewScreenState extends State<ClubMonthlyOverviewScreen> {
  final _scrollController = ScrollController();
  int? _selectedYear;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final globalContacts = context.read<GlobalContactsProvider>();
      final clubProvider = context.read<ClubProvider>();
      await globalContacts.loadContacts();
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

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<ClubProvider>().entries;
    final months = entries.map((e) => e.month).toSet().toList()
      ..sort((a, b) => b.compareTo(a));

    final years = months.map((m) => m.year).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    final filteredMonths = _selectedYear == null
        ? months
        : months.where((m) => m.year == _selectedYear).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('club_monthly_overview'.tr()),
        actions: [
          IconButton(
            tooltip: 'club_payment_history'.tr(),
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(builder: (_) => const ClubHistoryScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddEntry,
        icon: const Icon(Icons.add_rounded),
        label: Text('club_add_entry'.tr()),
      ),
      body: SafeArea(
        child: months.isEmpty
            ? ClubEmptyState(message: 'club_no_monthly_data'.tr())
            : Column(
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
                            onSelected: (_) =>
                                setState(() => _selectedYear = null),
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
                    child: filteredMonths.isEmpty
                        ? ClubEmptyState(
                            message: 'club_no_months_year'.tr())
                        : Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            child: ListView.builder(
                              controller: _scrollController,
                              padding:
                                  EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                              itemCount: filteredMonths.length,
                              itemBuilder: (context, index) {
                                final month = filteredMonths[index];
                                final monthEntries = entries
                                    .where((e) => e.month == month)
                                    .toList();
                                final collected = monthEntries
                                    .where(
                                        (e) => e.status == PaymentStatus.paid)
                                    .fold<double>(
                                        0, (sum, e) => sum + e.amount);
                                final due = monthEntries
                                    .where(
                                        (e) => e.status == PaymentStatus.due)
                                    .fold<double>(
                                        0, (sum, e) => sum + e.amount);
                                final advance = monthEntries
                                    .where((e) =>
                                        e.status == PaymentStatus.advance)
                                    .fold<double>(
                                        0, (sum, e) => sum + e.amount);
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
                                      builder: (_) =>
                                          ClubMonthDetailScreen(month: month),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
