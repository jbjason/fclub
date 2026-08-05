import 'package:fclub/feature/club/data/model/club_month_payment_filter.dart';
import 'package:fclub/feature/club/data/model/club_payment.dart';
import 'package:fclub/feature/club/presentation/widgets/shared/club_payment_status_filter_bar.dart';
import 'package:flutter/material.dart';

class ClubMonthPaymentFilterBar extends StatelessWidget {
  const ClubMonthPaymentFilterBar({
    super.key,
    required this.filter,
    required this.shownCount,
    required this.totalCount,
    required this.onStatusChanged,
    required this.onMoreFilters,
    required this.onClear,
  });

  final ClubMonthPaymentFilter filter;
  final int shownCount;
  final int totalCount;
  final ValueChanged<PaymentStatus?> onStatusChanged;
  final VoidCallback onMoreFilters;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ClubPaymentStatusFilterBar(
      selectedStatus: filter.status,
      hasActiveFilters: !filter.isEmpty,
      advancedFilterCount: filter.advancedFilterCount,
      shownCount: shownCount,
      totalCount: totalCount,
      onStatusChanged: onStatusChanged,
      onMoreFilters: onMoreFilters,
      onClear: onClear,
    );
  }
}
