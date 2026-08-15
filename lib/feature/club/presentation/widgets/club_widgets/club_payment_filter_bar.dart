import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/club/data/model/club_member.dart';
import 'package:fclub/feature/club/data/model/club_payment_filter.dart';
import 'package:fclub/feature/club/presentation/extensions/payment_display_extension.dart';
import 'package:fclub/feature/club/presentation/widgets/shared/club_payment_status_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClubPaymentFilterBar extends StatelessWidget {
  const ClubPaymentFilterBar({
    super.key,
    required this.filter,
    required this.members,
    required this.months,
    required this.shownCount,
    required this.totalCount,
    required this.onChanged,
  });

  final ClubPaymentFilter filter;
  final List<ClubMember> members;
  final List<String> months;
  final int shownCount;
  final int totalCount;
  final ValueChanged<ClubPaymentFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return ClubPaymentStatusFilterBar(
      selectedStatus: filter.status,
      hasActiveFilters: !filter.isEmpty,
      advancedFilterCount: filter.advancedFilterCount,
      shownCount: shownCount,
      totalCount: totalCount,
      onStatusChanged: (status) => onChanged(
        filter.copyWith(status: status, clearStatus: status == null),
      ),
      onMoreFilters: () => _showMoreFilters(context),
      onClear: () => onChanged(const ClubPaymentFilter()),
    );
  }

  Future<void> _showMoreFilters(BuildContext context) async {
    final selected = await showModalBottomSheet<ClubPaymentFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ClubPaymentFilterSheet(
        initialFilter: filter,
        members: members,
        months: months,
      ),
    );
    if (selected != null) onChanged(selected);
  }
}

class _ClubPaymentFilterSheet extends StatefulWidget {
  const _ClubPaymentFilterSheet({
    required this.initialFilter,
    required this.members,
    required this.months,
  });

  final ClubPaymentFilter initialFilter;
  final List<ClubMember> members;
  final List<String> months;

  @override
  State<_ClubPaymentFilterSheet> createState() =>
      _ClubPaymentFilterSheetState();
}

class _ClubPaymentFilterSheetState extends State<_ClubPaymentFilterSheet> {
  static const _allValue = '__all__';

  late String _userId;
  late String _month;
  late String _paymentMethod;

  @override
  void initState() {
    super.initState();
    _userId =
        widget.members.any((member) => member.id == widget.initialFilter.userId)
        ? widget.initialFilter.userId!
        : _allValue;
    _month = widget.months.contains(widget.initialFilter.month)
        ? widget.initialFilter.month!
        : _allValue;
    _paymentMethod = widget.initialFilter.paymentMethod?.value ?? _allValue;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'club_payment_more_filters'.tr(),
              style: TextStyle(
                fontFamily: MyString.poppinsBold,
                fontSize: 18.sp,
                color: colors.onSurface,
              ),
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              initialValue: _userId,
              decoration: InputDecoration(
                labelText: 'member'.tr(),
                prefixIcon: const Icon(Icons.person_search_rounded),
              ),
              items: [
                DropdownMenuItem(
                  value: _allValue,
                  child: Text('club_all_members'.tr()),
                ),
                ...widget.members.map(
                  (member) => DropdownMenuItem(
                    value: member.id,
                    child: Text(
                      member.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _userId = value);
              },
            ),
            SizedBox(height: 12.h),
            DropdownButtonFormField<String>(
              initialValue: _month,
              decoration: InputDecoration(
                labelText: 'club_payment_month'.tr(),
                prefixIcon: const Icon(Icons.calendar_month_rounded),
              ),
              items: [
                DropdownMenuItem(
                  value: _allValue,
                  child: Text('club_payment_all_months'.tr()),
                ),
                ...widget.months.map(
                  (month) => DropdownMenuItem(
                    value: month,
                    child: Text(_monthLabel(month)),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _month = value);
              },
            ),
            SizedBox(height: 12.h),
            DropdownButtonFormField<String>(
              initialValue: _paymentMethod,
              decoration: InputDecoration(
                labelText: 'club_payment_method'.tr(),
                prefixIcon: const Icon(Icons.account_balance_wallet_rounded),
              ),
              items: [
                DropdownMenuItem(
                  value: _allValue,
                  child: Text('club_all_payment_methods'.tr()),
                ),
                ...PaymentMethod.values.map(
                  (method) => DropdownMenuItem(
                    value: method.value,
                    child: Text(method.localizedLabel(context)),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _paymentMethod = value);
              },
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.pop(context, const ClubPaymentFilter()),
                    child: Text('club_reset_filters'.tr()),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(
                      context,
                      ClubPaymentFilter(
                        status: widget.initialFilter.status,
                        userId: _userId == _allValue ? null : _userId,
                        month: _month == _allValue ? null : _month,
                        paymentMethod: _paymentMethod == _allValue
                            ? null
                            : PaymentMethod.fromValue(_paymentMethod),
                      ),
                    ),
                    icon: const Icon(Icons.filter_alt_rounded),
                    label: Text('club_apply_filters'.tr()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _monthLabel(String month) {
    final date = DateTime.tryParse('$month-01');
    return date == null ? month : DateFormat('MMMM yyyy').format(date);
  }
}
