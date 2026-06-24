import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_member_model.dart';
import 'package:fclub/feature/kurbani/presentation/provider/kurbani_provider.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/kurbani_add_animal_part_sheet.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/kurbani_add_expense_sheet.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/kurbani_member_card.dart';
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

class KurbaniScreen extends StatefulWidget {
  const KurbaniScreen({super.key});

  @override
  State<KurbaniScreen> createState() => _KurbaniScreenState();
}

class _KurbaniScreenState extends State<KurbaniScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  final _costScrollController = ScrollController();
  final _animalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KurbaniProvider>().seedDemoData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _costScrollController.dispose();
    _animalScrollController.dispose();
    super.dispose();
  }

  // ── FAB ───────────────────────────────────────────────────

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
      backgroundColor: const Color(0xFFF8F7FC),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          // ── Hero app bar ──────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 280.h,
            backgroundColor: _kDeepEmerald,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: 20.r,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.tune_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 22.r,
                ),
                onPressed: () => _showBudgetDialog(context, provider),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              titlePadding: EdgeInsets.only(left: 56.w, bottom: 14.h),
              title: Text(
                provider.groupName,
                style: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  fontSize: 13.sp,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
              background: _KurbaniHeader(
                provider: provider,
                spendingProgress: summary.spendingProgress,
                totalBudget: summary.totalBudget,
                totalSpent: summary.totalSpent,
              ),
            ),
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
                unselectedLabelColor: Colors.black38,
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
                  Tab(icon: Icon(Icons.receipt_rounded, size: 18), text: 'Cost Split'),
                  Tab(icon: Icon(Icons.set_meal_rounded, size: 18), text: 'Animal Parts'),
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
            style: TextStyle(
              fontFamily: MyString.poppinsBold,
              fontSize: 13.sp,
            ),
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
          style: TextStyle(
            fontFamily: MyString.poppinsBold,
            fontSize: 16.sp,
          ),
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

// ── Header background widget ───────────────────────────────────────────────

class _KurbaniHeader extends StatelessWidget {
  const _KurbaniHeader({
    required this.provider,
    required this.spendingProgress,
    required this.totalBudget,
    required this.totalSpent,
  });

  final KurbaniProvider provider;
  final double spendingProgress;
  final double totalBudget;
  final double totalSpent;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -30,
            child: _DecoCircle(size: 150.r, opacity: 0.07),
          ),
          Positioned(
            top: 100,
            right: 60,
            child: _DecoCircle(size: 60.r, opacity: 0.10),
          ),
          Positioned(
            bottom: 30,
            left: -20,
            child: _DecoCircle(size: 100.r, opacity: 0.06),
          ),
          Positioned(
            top: 50,
            left: 80,
            child: _DecoCircle(size: 25.r, opacity: 0.14),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4.h),
                  // Crescent + group name row
                  Row(
                    children: [
                      _CrescentMoon(),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.groupName,
                              style: TextStyle(
                                fontFamily: MyString.poppinsBold,
                                fontSize: 18.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              '${provider.members.length} Members · Eid ul-Adha',
                              style: TextStyle(
                                fontFamily: MyString.rubikRegular,
                                fontSize: 11.sp,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Budget ring + member avatars row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Spending ring
                      _BudgetRing(
                        progress: spendingProgress,
                        totalBudget: totalBudget,
                        totalSpent: totalSpent,
                      ),
                      SizedBox(width: 20.w),
                      // Member avatar stack
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Participants',
                              style: TextStyle(
                                fontFamily: MyString.rubikRegular,
                                fontSize: 10.sp,
                                color: Colors.white54,
                                letterSpacing: 0.8,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            _MemberAvatarRow(members: provider.members),
                            SizedBox(height: 10.h),
                            // Per-person budget chip
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: _kGold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: _kGold.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.person_outline_rounded,
                                      size: 12.r, color: _kGold),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${CurrencyFormatter.format(provider.budgetPerMember)} / person',
                                    style: TextStyle(
                                      fontFamily: MyString.poppinsBold,
                                      fontSize: 10.sp,
                                      color: _kGold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _DecoCircle extends StatelessWidget {
  const _DecoCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _CrescentMoon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.r,
      height: 48.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            _kGold.withValues(alpha: 0.3),
            _kGold.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.nightlight_round,
          size: 28.r,
          color: _kGold,
        ),
      ),
    );
  }
}

class _BudgetRing extends StatelessWidget {
  const _BudgetRing({
    required this.progress,
    required this.totalBudget,
    required this.totalSpent,
  });

  final double progress;
  final double totalBudget;
  final double totalSpent;

  @override
  Widget build(BuildContext context) {
    final isOver = progress >= 1.0;
    final ringColor = isOver ? _kRose : _kEmerald;

    return SizedBox(
      width: 100.r,
      height: 100.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          SizedBox(
            width: 100.r,
            height: 100.r,
            child: CircularProgressIndicator(
              value: 1.0,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: 0.1)),
              strokeWidth: 8.r,
            ),
          ),
          // Progress arc
          SizedBox(
            width: 100.r,
            height: 100.r,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(ringColor),
              strokeWidth: 8.r,
              strokeCap: StrokeCap.round,
            ),
          ),
          // Center text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              Text(
                'spent',
                style: TextStyle(
                  fontFamily: MyString.rubikRegular,
                  fontSize: 9.sp,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MemberAvatarRow extends StatelessWidget {
  const _MemberAvatarRow({required this.members});

  final List<KurbaniMemberModel> members;

  @override
  Widget build(BuildContext context) {
    const maxVisible = 5;
    final visible = members.take(maxVisible).toList();
    final extra = members.length - maxVisible;

    return SizedBox(
      height: 34.r,
      child: Stack(
        children: [
          ...visible.asMap().entries.map((entry) {
            final i = entry.key;
            final member = entry.value;
            final gradients = kurbaniAvatarGradients[
                member.avatarColorIndex % kurbaniAvatarGradients.length];
            final initials = member.name.trim().split(' ').length >= 2
                ? '${member.name.split(' ')[0][0]}${member.name.split(' ')[1][0]}'
                    .toUpperCase()
                : member.name.substring(0, 1).toUpperCase();

            return Positioned(
              left: i * 22.0.w,
              child: Container(
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradients,
                  ),
                  border: Border.all(
                    color: const Color(0xFF064E3B),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontFamily: MyString.poppinsBold,
                      fontSize: 10.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }),
          if (extra > 0)
            Positioned(
              left: maxVisible * 22.0.w,
              child: Container(
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                  border: Border.all(
                    color: const Color(0xFF064E3B),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '+$extra',
                    style: TextStyle(
                      fontFamily: MyString.poppinsBold,
                      fontSize: 10.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
