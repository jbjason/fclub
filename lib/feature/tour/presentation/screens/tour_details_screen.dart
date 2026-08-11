import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/widgets/feature_ambient_background.dart';
import 'package:fclub/feature/tour/data/models/tour_participant.dart';
import 'package:fclub/feature/tour/presentation/provider/tour_event_provider.dart';
import 'package:fclub/feature/tour/presentation/screens/tour_summary_screen.dart';
import 'package:fclub/feature/tour/presentation/widgets/shared/tour_palette.dart';
import 'package:fclub/feature/tour/presentation/widgets/shared/tour_state_panel.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_details/tour_add_expense_sheet.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_details/tour_add_extra_payment_sheet.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_details/tour_budget_dialog.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_details/tour_budget_meter.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_details/tour_cost_manage_fab.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_details/tour_expenses_tab.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_details/tour_member_manage_sheet.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_details/tour_member_payment_dialog.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_details/tour_members_tab.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_details/tour_manage_app_bar.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_details/tour_payments_tab.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_details/tour_stat_card.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_details/tour_tab_bar_header_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TourDetailsScreen extends StatefulWidget {
  const TourDetailsScreen({super.key});
  @override
  State<TourDetailsScreen> createState() => _TourDetailsScreenState();
}

class _TourDetailsScreenState extends State<TourDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 3,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<TourEventProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TourEventProvider>();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: TourManageAppBar(
        title: provider.tourName,
        canEdit: provider.canEdit,
        onManageParticipants: _openParticipants,
        onEditBudget: () => _editBudget(provider),
        onOpenSummary: _openSummary,
      ),
      body: SafeArea(
        child: FeatureAmbientBackground(
          accent: TourPalette.ocean,
          secondaryAccent: TourPalette.orchid,
          child: _body(provider),
        ),
      ),
      floatingActionButton: provider.canEdit && !provider.isLoading
          ? TourCostManageFab(
              onAddExpense: () => showAddExpenseSheet(context),
              onAddExtraPayment: () => showAddExtraPaymentSheet(context),
            )
          : null,
    );
  }

  Widget _body(TourEventProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.loadError != null) {
      return TourStatePanel(
        icon: Icons.cloud_off_rounded,
        title: 'tour_load_error_title'.tr(),
        message: provider.loadError!.tr(),
        actionLabel: 'group_retry'.tr(),
        onAction: provider.initialize,
      );
    }
    if (!provider.canAccess) {
      return TourStatePanel(
        icon: Icons.lock_outline_rounded,
        title: 'project_access_required'.tr(),
        message: 'tour_access_required'.tr(),
      );
    }

    final summary = provider.summary;
    return NestedScrollView(
      headerSliverBuilder: (context, _) => [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: Row(
              children: [
                TourStatCard(
                  label: 'collected'.tr(),
                  amount: summary.totalCollected,
                  icon: Icons.savings_rounded,
                  color: TourPalette.lagoon,
                ),
                SizedBox(width: 9.w),
                TourStatCard(
                  label: 'spent'.tr(),
                  amount: summary.totalSpent,
                  icon: Icons.local_activity_rounded,
                  color: TourPalette.sunset,
                ),
                SizedBox(width: 9.w),
                TourStatCard(
                  label: 'balance'.tr(),
                  amount: summary.balance,
                  icon: Icons.account_balance_wallet_rounded,
                  color: summary.balance >= 0
                      ? TourPalette.ocean
                      : MyColor.error,
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 14.h),
            child: TourBudgetMeter(
              budget: provider.decidedBudget,
              spent: summary.totalSpent,
              progress: summary.budgetProgress,
              isOverBudget: summary.isOverBudget,
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: TourTabBarHeaderDelegate(
            TabBar(
              controller: _tabController,
              labelColor: TourPalette.ocean,
              unselectedLabelColor: Theme.of(context).colorScheme.outline,
              indicatorColor: TourPalette.sunset,
              indicatorWeight: 3,
              tabs: [
                Tab(text: 'expenses'.tr()),
                Tab(text: 'payments'.tr()),
                Tab(text: 'members'.tr()),
              ],
            ),
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          TourExpensesTab(
            expenses: provider.expenses,
            members: provider.members,
            onDelete: provider.canEdit ? _deleteExpense : null,
          ),
          TourPaymentsTab(
            payments: provider.extraPayments,
            members: provider.members,
            onDelete: provider.canEdit ? _deletePayment : null,
          ),
          TourMembersTab(
            members: provider.members,
            summary: summary,
            onEditPaidToManager: provider.canEdit
                ? (member) => _editParticipantPayment(provider, member)
                : (_) {},
          ),
        ],
      ),
    );
  }

  void _openParticipants() {
    final provider = context.read<TourEventProvider>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .64),
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: const TourMemberManageSheet(),
      ),
    );
  }

  void _openSummary() {
    final provider = context.read<TourEventProvider>();
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: const TourSummaryScreen(),
        ),
      ),
    );
  }

  Future<void> _editBudget(TourEventProvider provider) async {
    final amount = await showDialog<double>(
      context: context,
      builder: (_) => TourBudgetDialog(initialValue: provider.decidedBudget),
    );
    if (amount != null && mounted) {
      await _run(() => provider.updateBudget(amount));
    }
  }

  Future<void> _editParticipantPayment(
    TourEventProvider provider,
    TourParticipant member,
  ) async {
    final amount = await showDialog<double>(
      context: context,
      builder: (_) => TourMemberPaymentDialog(member: member),
    );
    if (amount != null && mounted) {
      await _run(() => provider.updateParticipantPayment(member.id, amount));
    }
  }

  void _deleteExpense(String expenseId) {
    _run(() => context.read<TourEventProvider>().deleteExpense(expenseId));
  }

  void _deletePayment(String paymentId) {
    _run(() => context.read<TourEventProvider>().deleteExtraPayment(paymentId));
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      if (!mounted) return;
      final key = context.read<TourEventProvider>().actionError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text((key ?? 'tour_error_unknown').tr())),
      );
    }
  }
}
