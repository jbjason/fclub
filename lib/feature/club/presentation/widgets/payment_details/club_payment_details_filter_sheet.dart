import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/club/data/model/club_member_payment_filter.dart';
import 'package:fclub/feature/club/presentation/extensions/payment_display_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClubPaymentDetailsFilterSheet extends StatefulWidget {
  const ClubPaymentDetailsFilterSheet({
    super.key,
    required this.initialFilter,
    required this.availableMonths,
  });

  final ClubMemberPaymentFilter initialFilter;
  final List<String> availableMonths;

  @override
  State<ClubPaymentDetailsFilterSheet> createState() =>
      _ClubPaymentDetailsFilterSheetState();
}

class _ClubPaymentDetailsFilterSheetState
    extends State<ClubPaymentDetailsFilterSheet> {
  static const _allValue = '__all__';

  late String _month;
  late String _paymentMethod;

  @override
  void initState() {
    super.initState();
    _month = widget.initialFilter.month ?? _allValue;
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
                ...widget.availableMonths.map(
                  (month) => DropdownMenuItem(
                    value: month,
                    child: Text(_formatMonth(context, month)),
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
                        Navigator.pop(context, const ClubMemberPaymentFilter()),
                    child: Text('club_reset_filters'.tr()),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(
                      context,
                      ClubMemberPaymentFilter(
                        status: widget.initialFilter.status,
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

  String _formatMonth(BuildContext context, String monthKey) {
    final parts = monthKey.split('-');
    if (parts.length != 2) return monthKey;
    final year = int.tryParse(parts.first);
    final month = int.tryParse(parts.last);
    if (year == null || month == null || month < 1 || month > 12) {
      return monthKey;
    }
    return MaterialLocalizations.of(
      context,
    ).formatMonthYear(DateTime(year, month));
  }
}
