import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/kurbani/presentation/provider/kurbani_provider.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/kurbani_add_animal_part_sheet.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/kurbani_add_expense_sheet.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/kurbani_member_manage_sheet.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/kurbani_stat_card.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/kurbani_tab_header_delegate.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/kurbani_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// ── Kurbani theme constants ────────────────────────────────────────────────
const _kDeepEmerald = Color(0xFF064E3B);
const _kGold = Color(0xFFF59E0B);
const _kEmerald = Color(0xFF10B981);
const _kRose = Color(0xFFEF4444);
const _kViolet = Color(0xFF6D28D9);
const _kCyan = Color(0xFF0891B2);

/// Full management screen for an active Kurbani session.
/// Navigated to from [KurbaniHistoryScreen].
class KurbaniManagementScreen extends StatefulWidget {
  const KurbaniManagementScreen({super.key});

  @override
  State<KurbaniManagementScreen> createState() =>
      _KurbaniManagementScreenState();
}

class _KurbaniManagementScreenState extends State<KurbaniManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  final _costScrollController = ScrollController();
  final _animalScrollController = ScrollController();

  @override
  void dispose() {
    _tabController.dispose();
    _costScrollController.dispose();
    _animalScrollController.dispose();
    super.dispose();
  }

  // ── FAB ───────────────────────────────────────────────────

  void _showMemberManageSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const KurbaniMemberManageSheet(),
    );
  }

  void _showAddExpenseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const KurbaniAddExpenseSheet(),
    );
  }

  void _showAddAnimalPartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const KurbaniAddAnimalPartSheet(),
    );
  }

  void _onFabPressed() {
    if (_tabController.index == 0) {
      _showAddExpenseSheet();
    } else {
      _showAddAnimalPartSheet();
    }
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KurbaniProvider>();
    final summary = provider.summary;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          // ── Hero app bar ──────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF064E3B),
                    Color(0xFF1A3A6B),
                    Color(0xFF1E1B4B),
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white70,
                size: 20.r,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _kGold.withValues(alpha: 0.3),
                        _kGold.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.nightlight_round,
                    size: 20.r,
                    color: _kGold,
                  ),
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      provider.groupName,
                      style: TextStyle(
                        fontFamily: MyString.poppinsBold,
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      '${provider.members.length} Members · Eid ul-Adha',
                      style: TextStyle(
                        fontFamily: MyString.rubikRegular,
                        fontSize: 10.sp,
                        color: Colors.white60,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.people_alt_rounded,
                  color: Colors.white,
                  size: 22.r,
                ),
                onPressed: _showMemberManageSheet,
                tooltip: 'Manage Members',
              ),
              IconButton(
                icon: Icon(
                  Icons.tune_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 22.r,
                ),
                onPressed: () => _showBudgetDialog(context, provider),
              ),
            ],
          ),

          // ── Stat cards row ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
              child: Row(
                children: [
                  KurbaniStatCard(
                    label: 'Budget',
                    amount: summary.totalBudget,
                    icon: Icons.savings_rounded,
                    color: _kViolet,
                  ),
                  SizedBox(width: 8.w),
                  KurbaniStatCard(
                    label: 'Spent',
                    amount: summary.totalSpent,
                    icon: Icons.shopping_bag_rounded,
                    color: _kCyan,
                  ),
                  SizedBox(width: 8.w),
                  KurbaniStatCard(
                    label: summary.isDeficit ? 'Deficit' : 'Surplus',
                    amount: summary.balance.abs(),
                    icon: summary.isDeficit
                        ? Icons.trending_down_rounded
                        : Icons.trending_up_rounded,
                    color: summary.isDeficit ? _kRose : _kEmerald,
                  ),
                ],
              ),
            ),
          ),

          // ── Pinned tab bar ────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: KurbaniTabHeaderDelegate(
              TabBar(
                controller: _tabController,
                labelColor: _kDeepEmerald,
                unselectedLabelColor: Theme.of(context).colorScheme.outline,
                indicatorColor: _kDeepEmerald,
                indicatorWeight: 2.5,
                labelStyle: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: TextStyle(
                  fontFamily: MyString.rubikRegular,
                  fontSize: 13.sp,
                ),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.receipt_rounded, size: 18),
                    text: 'Cost Split',
                  ),
                  Tab(
                    icon: Icon(Icons.set_meal_rounded, size: 18),
                    text: 'Animal Parts',
                  ),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            KurbaniCostTab(
              provider: provider,
              summary: summary,
              scrollController: _costScrollController,
            ),
            KurbaniAnimalTab(
              provider: provider,
              scrollController: _animalScrollController,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onFabPressed,
        backgroundColor: _kDeepEmerald,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add_rounded, size: 22.r),
        label: AnimatedBuilder(
          animation: _tabController,
          builder: (context, child) => Text(
            _tabController.index == 0 ? 'Add Expense' : 'Add Part',
            style: TextStyle(fontFamily: MyString.poppinsBold, fontSize: 13.sp),
          ),
        ),
      ),
    );
  }

  // ── Budget edit dialog ─────────────────────────────────────

  void _showBudgetDialog(BuildContext context, KurbaniProvider provider) {
    final controller = TextEditingController(
      text: provider.budgetPerMember.toStringAsFixed(0),
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Budget per Member',
          style: TextStyle(fontFamily: MyString.poppinsBold, fontSize: 16.sp),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: '৳ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final v = double.tryParse(controller.text.trim());
              if (v != null) provider.updateBudgetPerMember(v);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _kDeepEmerald,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

