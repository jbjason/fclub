import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/feature/club/presentation/provider/club_provider.dart';
import 'package:fclub/feature/club/presentation/screens/club_details/club_add_entry_screen.dart';
import 'package:fclub/feature/club/presentation/widgets/member_management/club_member_management_sheet.dart';
import 'package:fclub/feature/club/presentation/widgets/monthly_overview/club_dashboard_hero.dart';
import 'package:fclub/feature/club/presentation/widgets/monthly_overview/club_overview_tab.dart';
import 'package:fclub/feature/club/presentation/widgets/monthly_overview/club_payment_history_tab.dart';
import 'package:fclub/feature/club/presentation/widgets/shared/club_state_panel.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ClubProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClubProvider>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Fundora Club'),
        actions: [
          if (provider.isAdmin)
            IconButton.filledTonal(
              tooltip: 'Manage members',
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const ClubMemberManagementSheet(),
              ),
              icon: const Icon(Icons.group_add_rounded),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: provider.isLoading && provider.payments.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : provider.loadError != null
            ? ClubStatePanel(
                icon: Icons.cloud_off_rounded,
                title: 'Could not load Club',
                message: provider.loadError!,
                actionLabel: 'Try again',
                onAction: () => provider.initialize(force: true),
              )
            : Column(
                children: [
                  ClubDashboardHero(
                    summary: provider.currentMonthSummary,
                    isAdmin: provider.isAdmin,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(
                        alpha: .55,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      dividerHeight: 0,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: MyColor.primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: colors.onSurfaceVariant,
                      tabs: const [
                        Tab(
                          icon: Icon(Icons.auto_graph_rounded, size: 18),
                          text: 'Overview',
                        ),
                        Tab(
                          icon: Icon(Icons.receipt_long_rounded, size: 18),
                          text: 'Payments',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        ClubOverviewTab(summaries: provider.monthSummaries),
                        const ClubPaymentHistoryTab(),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton:
          provider.loadError == null && provider.currentMember != null
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const ClubAddEntryScreen()),
              ),
              icon: const Icon(Icons.add_card_rounded),
              label: const Text('Add Entry'),
            )
          : null,
    );
  }
}
