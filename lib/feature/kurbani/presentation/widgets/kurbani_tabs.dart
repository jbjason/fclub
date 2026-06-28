import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_summary.dart';
import 'package:fclub/feature/kurbani/presentation/provider/kurbani_provider.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/kurbani_animal_part_tile.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/kurbani_expense_tile.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/kurbani_member_card.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/kurbani_settlement_hero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class KurbaniCostTab extends StatelessWidget {
  const KurbaniCostTab({
    super.key,
    required this.provider,
    required this.summary,
    required this.scrollController,
  });

  final KurbaniProvider provider;
  final KurbaniSummary summary;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final members = provider.members;
    final expenses = provider.expenses;

    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.only(bottom: 100.h),
        children: [
          // Settlement summary hero
          KurbaniSettlementHero(summary: summary),

          // Member balances section
          _SectionHeader(
            icon: Icons.people_rounded,
            title: 'Member Balances',
            subtitle: '${summary.memberBalances.length} members',
            color: const Color(0xFF6D28D9),
          ),
          ...summary.memberBalances.map(
            (b) => KurbaniMemberCard(balance: b),
          ),
          SizedBox(height: 16.h),

          // Expenses section
          _SectionHeader(
            icon: Icons.receipt_long_rounded,
            title: 'Expenses',
            subtitle: '${expenses.length} entries · Total ${_formatAmount(summary.totalSpent)}',
            color: const Color(0xFF0891B2),
          ),
          if (expenses.isEmpty)
            _EmptyState(
              icon: Icons.receipt_long_outlined,
              message: 'No expenses yet.\nTap + to add one.',
            )
          else
            ...expenses.map(
              (e) => KurbaniExpenseTile(
                expense: e,
                members: members,
                onDelete: () => provider.deleteExpense(e.id),
              ),
            ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  String _formatAmount(double amount) =>
      '৳${amount.toStringAsFixed(0)}';
}

class KurbaniAnimalTab extends StatelessWidget {
  const KurbaniAnimalTab({
    super.key,
    required this.provider,
    required this.scrollController,
  });

  final KurbaniProvider provider;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final parts = provider.animalParts;
    final total = provider.totalAnimalWeight;

    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.only(bottom: 100.h),
        children: [
          // Total weight hero
          _AnimalWeightHero(totalWeight: total, partCount: parts.length),
          SizedBox(height: 8.h),

          // Parts section
          _SectionHeader(
            icon: Icons.set_meal_rounded,
            title: 'Parts Breakdown',
            subtitle: '${parts.length} parts recorded',
            color: const Color(0xFF7C2D12),
          ),
          if (parts.isEmpty)
            _EmptyState(
              icon: Icons.set_meal_outlined,
              message: 'No animal parts recorded yet.\nTap + to add.',
            )
          else
            ...parts.map(
              (p) => KurbaniAnimalPartTile(
                part: p,
                totalWeight: total,
                onDelete: () => provider.deleteAnimalPart(p.id),
              ),
            ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}

// ── Private helpers ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(7.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 16.r, color: color),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: MyString.rubikRegular,
                  fontSize: 10.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Column(
        children: [
          Icon(icon, size: 48.r, color: colorScheme.outlineVariant),
          SizedBox(height: 12.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: MyString.rubikRegular,
              fontSize: 13.sp,
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimalWeightHero extends StatelessWidget {
  const _AnimalWeightHero({
    required this.totalWeight,
    required this.partCount,
  });

  final double totalWeight;
  final int partCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C2D12), Color(0xFF6D28D9)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C2D12).withValues(alpha: 0.35),
            blurRadius: 24.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70.r,
            height: 70.r,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.set_meal_rounded,
              size: 34.r,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Animal Weight',
                  style: TextStyle(
                    fontFamily: MyString.rubikRegular,
                    fontSize: 11.sp,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${totalWeight.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    fontFamily: MyString.poppinsBold,
                    fontSize: 30.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '$partCount parts recorded',
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
    );
  }
}
