import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/club/data/model/club_member.dart';
import 'package:fclub/feature/club/data/model/club_month_payment_filter.dart';
import 'package:fclub/feature/club/presentation/extensions/payment_display_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClubMonthPaymentFilterSheet extends StatefulWidget {
  const ClubMonthPaymentFilterSheet({
    super.key,
    required this.initialFilter,
    required this.members,
  });

  final ClubMonthPaymentFilter initialFilter;
  final List<ClubMember> members;

  @override
  State<ClubMonthPaymentFilterSheet> createState() =>
      _ClubMonthPaymentFilterSheetState();
}

class _ClubMonthPaymentFilterSheetState
    extends State<ClubMonthPaymentFilterSheet> {
  static const _allValue = '__all__';

  late String _userId;
  late String _paymentMethod;

  @override
  void initState() {
    super.initState();
    final initialUserId = widget.initialFilter.userId;
    final hasInitialUser = widget.members.any(
      (member) => member.id == initialUserId,
    );
    _userId = hasInitialUser ? initialUserId! : _allValue;
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
                        Navigator.pop(context, const ClubMonthPaymentFilter()),
                    child: Text('club_reset_filters'.tr()),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(
                      context,
                      ClubMonthPaymentFilter(
                        status: widget.initialFilter.status,
                        userId: _userId == _allValue ? null : _userId,
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
}
