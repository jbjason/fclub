import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/config/router/app_router.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/tour/data/model/tour_member_model.dart';
import 'package:fclub/feature/tour/presentation/provider/tour_provider.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_cost_manage/tour_cost_manage_fab.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_cost_manage/tour_expenses_tab.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_cost_manage/tour_member_manage_sheet.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_cost_manage/tour_members_tab.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_cost_manage/tour_payments_tab.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_cost_manage/tour_stat_card.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_cost_manage/tour_add_expense_sheet.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_cost_manage/tour_add_extra_payment_sheet.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_cost_manage/tour_tab_bar_header_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TourCostManageScreen extends StatefulWidget {
  const TourCostManageScreen({super.key});

  @override
  State<TourCostManageScreen> createState() => _TourCostManageScreenState();
}

class _TourCostManageScreenState extends State<TourCostManageScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 3,
    vsync: this,
  );

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tourProvider = context.watch<TourProvider>();
    final summary = tourProvider.summary;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          _buildSliverAppBar(tourProvider),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: Row(
                children: [
                  TourStatCard(
                    label: 'collected'.tr(),
                    amount: summary.totalCollected,
                    icon: Icons.savings_rounded,
                    color: MyColor.secondary,
                  ),
                  SizedBox(width: 10.w),
                  TourStatCard(
                    label: 'spent'.tr(),
                    amount: summary.totalSpent,
                    icon: Icons.shopping_bag_rounded,
                    color: MyColor.tertiary,
                  ),
                  SizedBox(width: 10.w),
                  TourStatCard(
                    label: 'balance'.tr(),
                    amount: summary.balance,
                    icon: Icons.account_balance_wallet_rounded,
                    color: summary.balance >= 0 ? MyColor.primary : MyColor.error,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'tour_total_budget'.tr(),
                        style: TextStyle(
                          fontFamily: MyString.rubikRegular,
                          fontSize: 12.sp,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(tourProvider.decidedBudget),
                        style: TextStyle(
                          fontFamily: MyString.poppinsBold,
                          fontSize: 13.sp,
                          color: summary.isOverBudget
                              ? MyColor.error
                              : MyColor.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: LinearProgressIndicator(
                      value: summary.budgetProgress,
                      minHeight: 8.h,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        summary.isOverBudget
                            ? MyColor.error
                            : MyColor.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: TourTabBarHeaderDelegate(
              TabBar(
                controller: _tabController,
                labelColor: MyColor.primary,
                unselectedLabelColor: Theme.of(context).colorScheme.outline,
                indicatorColor: MyColor.primary,
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
            TourExpensesTab(expenses: tourProvider.expenses, members: tourProvider.members),
            TourPaymentsTab(payments: tourProvider.extraPayments, members: tourProvider.members),
            TourMembersTab(
              members: tourProvider.members,
              summary: summary,
              onEditPaidToManager: (member) =>
                  _showEditPaidToManagerDialog(context, tourProvider, member),
            ),
          ],
        ),
      ),
      floatingActionButton: TourCostManageFab(
        onAddExpense: () => showAddExpenseSheet(context),
        onAddExtraPayment: () => showAddExtraPaymentSheet(context),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(TourProvider tourProvider) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: MyColor.primary,
      foregroundColor: MyColor.onPrimary,
      title: Text(
        tourProvider.tourName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: MyString.poppinsBold,
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [MyColor.primary, MyColor.secondary, MyColor.tertiary],
          ),
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'manage_members'.tr(),
          icon: const Icon(Icons.people_alt_rounded),
          onPressed: _showMemberManageSheet,
        ),
        IconButton(
          tooltip: 'tour_edit_budget'.tr(),
          icon: const Icon(Icons.tune_rounded),
          onPressed: () => _showBudgetDialog(tourProvider),
        ),
        IconButton(
          tooltip: 'settlement_summary'.tr(),
          icon: const Icon(Icons.receipt_long_rounded),
          onPressed: () =>
              Navigator.pushNamed(context, AppRouteName.tourSummary),
        ),
      ],
    );
  }

  void _showMemberManageSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TourMemberManageSheet(),
    );
  }

  Future<void> _showBudgetDialog(TourProvider tourProvider) async {
    final newBudget = await showDialog<double>(
      context: context,
      builder: (_) => _BudgetDialog(
        initialValue: tourProvider.decidedBudget,
      ),
    );
    if (newBudget != null && mounted) {
      tourProvider.updateDecidedBudget(newBudget);
    }
  }

  Future<void> _showEditPaidToManagerDialog(
    BuildContext context,
    TourProvider tourProvider,
    TourMemberModel member,
  ) async {
    final controller = TextEditingController(
      text: member.paidToManager == 0 ? '' : member.paidToManager.toStringAsFixed(0),
    );
    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${member.name} — paid to manager'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: 'amount'.tr()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              double.tryParse(controller.text.trim()) ?? 0,
            ),
            child: Text('save'.tr()),
          ),
        ],
      ),
    );

    if (amount != null) {
      await tourProvider.updateMemberPaidToManager(member.id, amount);
    }
  }
}

class _BudgetDialog extends StatefulWidget {
  const _BudgetDialog({required this.initialValue});
  final double initialValue;

  @override
  State<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<_BudgetDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Text(
        'total_budget'.tr(),
        style: TextStyle(fontFamily: MyString.poppinsBold, fontSize: 16.sp),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          prefixText: '৳ ',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(
            context,
            double.tryParse(_controller.text.trim()),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: MyColor.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          child: Text('save'.tr()),
        ),
      ],
    );
  }
}
