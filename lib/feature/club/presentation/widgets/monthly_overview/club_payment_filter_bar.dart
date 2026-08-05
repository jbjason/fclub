import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/club/data/model/club_member.dart';
import 'package:fclub/feature/club/data/model/club_payment_filter.dart';
import 'package:fclub/feature/club/presentation/provider/club_provider.dart';
import 'package:fclub/feature/club/presentation/extensions/payment_display_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ClubPaymentFilterBar extends StatelessWidget {
  const ClubPaymentFilterBar({
    super.key,
    required this.filter,
    required this.members,
    required this.onChanged,
  });

  final ClubPaymentFilter filter;
  final List<ClubMember> members;
  final ValueChanged<ClubPaymentFilter> onChanged;

  int get _activeCount => [
    filter.userId,
    filter.month,
    filter.status,
    filter.paymentMethod,
  ].where((value) => value != null).length;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16.r),
              onTap: () async {
                final selected = await showModalBottomSheet<ClubPaymentFilter>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) =>
                      _FilterSheet(initial: filter, members: members),
                );
                if (selected != null) onChanged(selected);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
                decoration: BoxDecoration(
                  color: MyColor.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: MyColor.primary.withValues(alpha: .2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 18.r,
                      color: MyColor.primary,
                    ),
                    SizedBox(width: 9.w),
                    Text(
                      _activeCount == 0
                          ? 'Filter payments'
                          : '$_activeCount filters active',
                      style: TextStyle(
                        fontFamily: MyString.poppinsMedium,
                        fontSize: 12.sp,
                        color: MyColor.primary,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20.r,
                      color: MyColor.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_activeCount > 0) ...[
            SizedBox(width: 8.w),
            IconButton.filledTonal(
              tooltip: 'Clear filters',
              onPressed: () => onChanged(const ClubPaymentFilter()),
              icon: const Icon(Icons.filter_alt_off_rounded),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial, required this.members});

  final ClubPaymentFilter initial;
  final List<ClubMember> members;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _userId;
  String? _month;
  PaymentStatus? _status;
  PaymentMethod? _method;

  @override
  void initState() {
    super.initState();
    _userId = widget.initial.userId;
    _month = widget.initial.month;
    _status = widget.initial.status;
    _method = widget.initial.paymentMethod;
  }

  List<DateTime> get _months {
    final now = DateTime.now();
    return List.generate(
      22,
      (index) => DateTime(now.year, now.month + 3 - index),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        10.h,
        20.w,
        MediaQuery.viewInsetsOf(context).bottom + 24.h,
      ),
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
              'Filter Firestore payments',
              style: TextStyle(
                fontFamily: MyString.poppinsBold,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              initialValue: _userId,
              decoration: const InputDecoration(
                labelText: 'Member',
                prefixIcon: Icon(Icons.person_search_rounded),
              ),
              items: widget.members
                  .map(
                    (member) => DropdownMenuItem(
                      value: member.id,
                      child: Text(member.name, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) => setState(() => _userId = value),
            ),
            SizedBox(height: 12.h),
            DropdownButtonFormField<String>(
              initialValue: _month,
              decoration: const InputDecoration(
                labelText: 'Month',
                prefixIcon: Icon(Icons.calendar_month_rounded),
              ),
              items: _months
                  .map(
                    (month) => DropdownMenuItem(
                      value: ClubProvider.monthKey(month),
                      child: Text(DateFormat('MMMM yyyy').format(month)),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) => setState(() => _month = value),
            ),
            SizedBox(height: 12.h),
            DropdownButtonFormField<PaymentStatus>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.fact_check_rounded),
              ),
              items: PaymentStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.label),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) => setState(() => _status = value),
            ),
            SizedBox(height: 12.h),
            DropdownButtonFormField<PaymentMethod>(
              initialValue: _method,
              decoration: const InputDecoration(
                labelText: 'Payment method',
                prefixIcon: Icon(Icons.account_balance_wallet_rounded),
              ),
              items: PaymentMethod.values
                  .map(
                    (method) => DropdownMenuItem(
                      value: method,
                      child: Text(method.label),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) => setState(() => _method = value),
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      _userId = null;
                      _month = null;
                      _status = null;
                      _method = null;
                    }),
                    child: const Text('Reset'),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(
                      context,
                      ClubPaymentFilter(
                        userId: _userId,
                        month: _month,
                        status: _status,
                        paymentMethod: _method,
                      ),
                    ),
                    icon: const Icon(Icons.cloud_sync_rounded),
                    label: const Text('Apply API filter'),
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
