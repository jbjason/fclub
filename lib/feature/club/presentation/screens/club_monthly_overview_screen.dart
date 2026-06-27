import 'package:fclub/feature/club/data/model/payment_status.dart';
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<ClubProvider>().entries;
    final months = entries.map((e) => e.month).toSet().toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Monthly Overview')),
      body: SafeArea(
        child: months.isEmpty
            ? const ClubEmptyState(message: 'No monthly data yet.')
            : Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    final month = months[index];
                    final monthEntries =
                        entries.where((e) => e.month == month).toList();
                    final collected = monthEntries
                        .where((e) => e.status == PaymentStatus.paid)
                        .fold<double>(0, (sum, e) => sum + e.amount);
                    final due = monthEntries
                        .where((e) => e.status == PaymentStatus.due)
                        .fold<double>(0, (sum, e) => sum + e.amount);
                    final advance = monthEntries
                        .where((e) => e.status == PaymentStatus.advance)
                        .fold<double>(0, (sum, e) => sum + e.amount);
                    final memberCount =
                        monthEntries.map((e) => e.contactId).toSet().length;

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
    );
  }
}
