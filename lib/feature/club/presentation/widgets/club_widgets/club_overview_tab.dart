import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/feature/club/data/model/club_month_summary.dart';
import 'package:fclub/feature/club/presentation/screens/club_details/club_month_payment_details_screen.dart';
import 'package:fclub/feature/club/presentation/widgets/club_widgets/club_month_summary_card.dart';
import 'package:fclub/feature/club/presentation/widgets/shared/club_state_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClubOverviewTab extends StatefulWidget {
  const ClubOverviewTab({
    super.key,
    required this.summaries,
    required this.onRefresh,
  });

  final List<ClubMonthSummary> summaries;
  final Future<void> Function() onRefresh;

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
                label: Text('club_filter_all_years'.tr()),
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
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: visible.isEmpty
                ? LayoutBuilder(
                    builder: (context, constraints) => ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: constraints.maxHeight,
                          child: ClubStatePanel(
                            icon: Icons.calendar_view_month_rounded,
                            title: 'club_no_monthly_data'.tr(),
                            message: 'club_no_monthly_data_message'.tr(),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final summary = visible[index];
                      return ClubMonthSummaryCard(
                        summary: summary,
                        onTap: () => Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClubMonthPaymentDetailsScreen(
                              month: summary.month,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
