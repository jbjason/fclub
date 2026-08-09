import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/widgets/feature_ambient_background.dart';
import 'package:fclub/feature/club/presentation/provider/club_provider.dart';
import 'package:fclub/feature/club/presentation/screens/club_details/club_add_entry_screen.dart';
import 'package:fclub/feature/club/presentation/widgets/member_management/club_member_management_sheet.dart';
import 'package:fclub/feature/club/presentation/widgets/monthly_overview/club_dashboard_hero.dart';
import 'package:fclub/feature/club/presentation/widgets/monthly_overview/club_overview_tab.dart';
import 'package:fclub/feature/club/presentation/widgets/monthly_overview/club_payment_history_tab.dart';
import 'package:fclub/feature/club/presentation/widgets/project_setup/club_project_setup_panel.dart';
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
        backgroundColor: colors.surface.withValues(alpha: .92),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.projectName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'club_page_kicker'.tr(),
              style: TextStyle(
                color: MyColor.primary,
                fontFamily: MyString.rubikMedium,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          if (provider.canManageParticipants && provider.project != null)
            IconButton.filledTonal(
              tooltip: 'club_manage_members'.tr(),
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
        child: FeatureAmbientBackground(
          accent: MyColor.primary,
          secondaryAccent: MyColor.secondary,
          child: provider.isLoading && provider.payments.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : provider.loadError != null
              ? ClubStatePanel(
                  icon: Icons.cloud_off_rounded,
                  title: 'club_load_error_title'.tr(),
                  message: provider.loadError!,
                  actionLabel: 'group_retry'.tr(),
                  onAction: () => provider.initialize(force: true),
                )
              : provider.project == null
              ? const ClubProjectSetupPanel()
              : !provider.canAccessProject
              ? ClubStatePanel(
                  icon: Icons.lock_outline_rounded,
                  title: 'project_access_required'.tr(),
                  message: 'club_access_required_message'.tr(),
                )
              : Column(
                  children: [
                    ClubDashboardHero(
                      summary: provider.currentMonthSummary,
                      isAdmin: provider.isAdmin,
                    ),
                    Container(
                      height: 54,
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLowest.withValues(
                          alpha: .9,
                        ),
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(
                          color: MyColor.primary.withValues(alpha: .14),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: MyColor.primary.withValues(alpha: .08),
                            blurRadius: 18,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: TabBar(
                        controller: _tabController,
                        dividerHeight: 0,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFA855F7), Color(0xFF7C3AED)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: MyColor.primary.withValues(alpha: .28),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: colors.onSurfaceVariant,
                        labelStyle: const TextStyle(
                          fontFamily: MyString.rubikMedium,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                        tabs: [
                          Tab(
                            icon: const Icon(
                              Icons.auto_graph_rounded,
                              size: 18,
                            ),
                            text: 'club_tab_overview'.tr(),
                          ),
                          Tab(
                            icon: const Icon(
                              Icons.receipt_long_rounded,
                              size: 18,
                            ),
                            text: 'club_tab_payments'.tr(),
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
      ),
      floatingActionButton:
          provider.loadError == null && provider.currentMember != null
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const ClubAddEntryScreen()),
              ),
              icon: const Icon(Icons.add_card_rounded),
              label: Text('club_add_entry'.tr()),
            )
          : null,
    );
  }
}
