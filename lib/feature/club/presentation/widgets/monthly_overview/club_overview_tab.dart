import 'package:fclub/feature/club/data/model/club_month_summary.dart';
import 'package:fclub/feature/club/presentation/widgets/monthly_overview/club_month_summary_card.dart';
import 'package:fclub/feature/club/presentation/widgets/shared/club_state_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClubOverviewTab extends StatefulWidget {
  const ClubOverviewTab({super.key, required this.summaries});

  final List<ClubMonthSummary> summaries;

  @override
  State<ClubOverviewTab> createState() => _ClubOverviewTabState();
}

class _ClubOverviewTabState extends State<ClubOverviewTab> {
  int? _year;

  @override
  Widget build(BuildContext context) {
    final years = widget.summaries.map((summary) => summary.month.year).toSet()
      ..add(DateTime.now().year);
    final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));
    final visible = _year == null
        ? widget.summaries
        : widget.summaries
              .where((summary) => summary.month.year == _year)
              .toList(growable: false);

    return Column(
      children: [
        SizedBox(
          height: 50.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            children: [
              ChoiceChip(
                label: const Text('All years'),
                selected: _year == null,
                onSelected: (_) => setState(() => _year = null),
              ),
              ...sortedYears.map(
                (year) => Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: ChoiceChip(
                    label: Text('$year'),
                    selected: _year == year,
                    onSelected: (_) => setState(() => _year = year),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? const ClubStatePanel(
                  icon: Icons.calendar_view_month_rounded,
                  title: 'No monthly records',
                  message: 'Add a payment to start this year’s Club timeline.',
                )
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
                  itemCount: visible.length,
                  itemBuilder: (_, index) =>
                      ClubMonthSummaryCard(summary: visible[index]),
                ),
        ),
      ],
    );
  }
}
