import 'package:fclub/config/router/app_router.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/tour/data/model/tour_member_model.dart';
import 'package:fclub/feature/tour/presentation/provider/tour_provider.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_cost_manage/tour_cost_manage_fab.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_cost_manage/tour_expenses_tab.dart';
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
                    label: 'Collected',
                    amount: summary.totalCollected,
                    icon: Icons.savings_rounded,
                    color: MyColor.secondary,
                  ),
                  SizedBox(width: 10.w),
                  TourStatCard(
                    label: 'Spent',
                    amount: summary.totalSpent,
                    icon: Icons.shopping_bag_rounded,
                    color: MyColor.tertiary,
                  ),
                  SizedBox(width: 10.w),
                  TourStatCard(
                    label: 'Balance',
                    amount: summary.balance,
                    icon: Icons.account_balance_wallet_rounded,
                    color: summary.balance >= 0 ? MyColor.primary : MyColor.error,
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
                tabs: const [
                  Tab(text: 'Expenses'),
                  Tab(text: 'Payments'),
                  Tab(text: 'Members'),
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
          tooltip: 'Settlement summary',
          icon: const Icon(Icons.receipt_long_rounded),
          onPressed: () =>
              Navigator.pushNamed(context, AppRouteName.tourSummary),
        ),
      ],
    );
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
          decoration: const InputDecoration(labelText: 'Amount'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              double.tryParse(controller.text.trim()) ?? 0,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (amount != null) {
      await tourProvider.updateMemberPaidToManager(member.id, amount);
    }
  }
}
