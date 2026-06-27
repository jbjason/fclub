import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/club/data/model/payment_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

/// Search box + month/status filter chips for the History screen.
class ClubFilterBar extends StatelessWidget {
  const ClubFilterBar({
    super.key,
    required this.onSearchChanged,
    this.showMonthFilter = true,
    this.availableMonths = const [],
    this.selectedMonth,
    this.onMonthChanged,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  final ValueChanged<String> onSearchChanged;

  /// Set to false when the caller already scopes entries to a single month
  /// (e.g. [ClubMonthDetailScreen]) — hides the month chip entirely.
  final bool showMonthFilter;
  final List<DateTime> availableMonths;
  final DateTime? selectedMonth;
  final ValueChanged<DateTime?>? onMonthChanged;
  final PaymentStatus? selectedStatus;
  final ValueChanged<PaymentStatus?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search member name',
            prefixIcon: const Icon(Icons.search_rounded),
          ),
        ),
        SizedBox(height: 10.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              if (showMonthFilter && onMonthChanged != null) ...[
                _MonthChip(
                  availableMonths: availableMonths,
                  selectedMonth: selectedMonth,
                  onMonthChanged: onMonthChanged!,
                ),
                SizedBox(width: 8.w),
              ],
              _StatusChip(
                label: 'All',
                isSelected: selectedStatus == null,
                color: colorScheme.primary,
                onTap: () => onStatusChanged(null),
              ),
              ...PaymentStatus.values.map((status) {
                return Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: _StatusChip(
                    label: status.label,
                    isSelected: selectedStatus == status,
                    color: status.color,
                    onTap: () => onStatusChanged(status),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _MonthChip extends StatelessWidget {
  const _MonthChip({
    required this.availableMonths,
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  final List<DateTime> availableMonths;
  final DateTime? selectedMonth;
  final ValueChanged<DateTime?> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DateTime?>(
      initialValue: selectedMonth,
      onSelected: onMonthChanged,
      itemBuilder: (context) => [
        const PopupMenuItem(value: null, child: Text('All months')),
        ...availableMonths.map((month) {
          return PopupMenuItem(
            value: month,
            child: Text(DateFormat('MMMM yyyy').format(month)),
          );
        }),
      ],
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: MyColor.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: MyColor.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month_rounded, size: 14.r, color: MyColor.primary),
            SizedBox(width: 6.w),
            Text(
              selectedMonth == null
                  ? 'All months'
                  : DateFormat('MMM yyyy').format(selectedMonth!),
              style: TextStyle(
                fontFamily: MyString.poppinsMedium,
                fontSize: 12.sp,
                color: MyColor.primary,
              ),
            ),
            Icon(Icons.arrow_drop_down_rounded, color: MyColor.primary, size: 16.r),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withValues(alpha: isSelected ? 1 : 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: MyString.poppinsMedium,
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}
