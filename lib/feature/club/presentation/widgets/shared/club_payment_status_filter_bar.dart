import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/club/presentation/extensions/payment_display_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClubPaymentStatusFilterBar extends StatelessWidget {
  const ClubPaymentStatusFilterBar({
    super.key,
    required this.selectedStatus,
    required this.hasActiveFilters,
    required this.advancedFilterCount,
    required this.shownCount,
    required this.totalCount,
    required this.onStatusChanged,
    required this.onMoreFilters,
    required this.onClear,
  });

  final PaymentStatus? selectedStatus;
  final bool hasActiveFilters;
  final int advancedFilterCount;
  final int shownCount;
  final int totalCount;
  final ValueChanged<PaymentStatus?> onStatusChanged;
  final VoidCallback onMoreFilters;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'club_payment_showing_count'.tr(
                    namedArgs: {'shown': '$shownCount', 'total': '$totalCount'},
                  ),
                  style: TextStyle(
                    fontFamily: MyString.poppinsMedium,
                    fontSize: 11.sp,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              if (hasActiveFilters)
                TextButton(
                  onPressed: onClear,
                  child: Text('club_clear_filters'.tr()),
                ),
            ],
          ),
          SizedBox(height: 4.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _statusChip(
                  context,
                  label: 'club_all_statuses'.tr(),
                  selected: selectedStatus == null,
                  onSelected: () => onStatusChanged(null),
                ),
                ...PaymentStatus.values.map(
                  (status) => Padding(
                    padding: EdgeInsets.only(left: 7.w),
                    child: _statusChip(
                      context,
                      label: status.localizedLabel(context),
                      selected: selectedStatus == status,
                      onSelected: () => onStatusChanged(status),
                    ),
                  ),
                ),
                SizedBox(width: 7.w),
                Badge(
                  isLabelVisible: advancedFilterCount > 0,
                  label: Text('$advancedFilterCount'),
                  child: OutlinedButton.icon(
                    onPressed: onMoreFilters,
                    icon: const Icon(Icons.tune_rounded),
                    label: Text('club_payment_more_filters'.tr()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: MyColor.primary,
                      side: BorderSide(
                        color: MyColor.primary.withValues(alpha: .35),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    final colors = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: MyColor.primary.withValues(alpha: .16),
      side: BorderSide(
        color: selected
            ? MyColor.primary.withValues(alpha: .45)
            : colors.outlineVariant.withValues(alpha: .75),
      ),
      labelStyle: TextStyle(
        color: selected ? MyColor.primary : colors.onSurfaceVariant,
        fontFamily: MyString.rubikMedium,
        fontSize: 10.sp,
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}
