import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/club/data/model/club_member.dart';
import 'package:fclub/feature/club/data/model/club_payment.dart';
import 'package:fclub/feature/club/presentation/widgets/add_entry/club_payment_member_picker.dart';
import 'package:fclub/feature/club/presentation/widgets/add_entry/club_payment_method_selector.dart';
import 'package:fclub/feature/club/presentation/widgets/club_card_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

typedef ClubPaymentFormSubmit =
    Future<void> Function({
      required String? memberId,
      required double amount,
      required DateTime month,
      required PaymentMethod paymentMethod,
      String? note,
    });

class ClubPaymentForm extends StatefulWidget {
  const ClubPaymentForm({
    super.key,
    required this.members,
    required this.currentMember,
    required this.isAdmin,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onManageMembers,
    required this.suggestedAmount,
    this.initialMonth,
  });

  final List<ClubMember> members;
  final ClubMember? currentMember;
  final bool isAdmin;
  final bool isSubmitting;
  final DateTime? initialMonth;
  final ClubPaymentFormSubmit onSubmit;
  final VoidCallback onManageMembers;
  final double suggestedAmount;

  @override
  State<ClubPaymentForm> createState() => _ClubPaymentFormState();
}

class _ClubPaymentFormState extends State<ClubPaymentForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  final _noteController = TextEditingController();

  String? _memberId;
  late DateTime _month;
  PaymentMethod _paymentMethod = PaymentMethod.cash;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.suggestedAmount.toStringAsFixed(0),
    );
    final now = DateTime.now();
    final initial = widget.initialMonth ?? now;
    _month = DateTime(initial.year, initial.month);
    _memberId = widget.isAdmin
        ? (widget.currentMember?.id ?? widget.members.firstOrNull?.id)
        : widget.currentMember?.id;
  }

  @override
  void didUpdateWidget(covariant ClubPaymentForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isAdmin) {
      _memberId = widget.currentMember?.id;
      return;
    }
    final selectedStillExists = widget.members.any(
      (member) => member.id == _memberId,
    );
    if (!selectedStillExists) {
      _memberId = widget.currentMember?.id ?? widget.members.firstOrNull?.id;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<DateTime> get _months {
    final now = DateTime.now();
    return List.generate(
      22,
      (index) => DateTime(now.year, now.month + 3 - index),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_memberId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select a group member.')));
      return;
    }
    await widget.onSubmit(
      memberId: _memberId,
      amount: double.parse(_amountController.text.trim()),
      month: _month,
      paymentMethod: _paymentMethod,
      note: _noteController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Form(
      key: _formKey,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 32.h),
        children: [
          ClubCardShell(
            accent: widget.isAdmin ? MyColor.success : MyColor.warning,
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 45.r,
                  height: 45.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (widget.isAdmin ? MyColor.success : MyColor.warning)
                        .withValues(alpha: .12),
                  ),
                  child: Icon(
                    widget.isAdmin
                        ? Icons.verified_user_rounded
                        : Icons.hourglass_top_rounded,
                    color: widget.isAdmin ? MyColor.success : MyColor.warning,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isAdmin
                            ? 'Admin-confirmed payment'
                            : 'Submit for admin review',
                        style: TextStyle(
                          fontFamily: MyString.poppinsBold,
                          fontSize: 13.sp,
                          color: colors.onSurface,
                        ),
                      ),
                      Text(
                        widget.isAdmin
                            ? 'This entry will be saved as paid.'
                            : 'Your entry will be saved as pending.',
                        style: TextStyle(
                          fontFamily: MyString.rubikRegular,
                          fontSize: 10.sp,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          ClubPaymentMemberPicker(
            members: widget.members,
            currentMember: widget.currentMember,
            isAdmin: widget.isAdmin,
            selectedMemberId: _memberId,
            onSelected: (memberId) => setState(() => _memberId = memberId),
            onManageMembers: widget.onManageMembers,
          ),
          SizedBox(height: 18.h),
          _Label(text: 'PAYMENT DETAILS'),
          SizedBox(height: 8.h),
          DropdownButtonFormField<DateTime>(
            initialValue: _month,
            decoration: InputDecoration(
              labelText: 'Contribution month',
              prefixIcon: Icon(Icons.calendar_month_rounded),
            ),
            items: _months
                .map(
                  (month) => DropdownMenuItem(
                    value: month,
                    child: Text(DateFormat('MMMM yyyy').format(month)),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) setState(() => _month = value);
            },
          ),
          SizedBox(height: 12.h),
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              labelText: 'Amount (৳)',
              prefixIcon: Icon(Icons.savings_rounded),
              helperText:
                  'Monthly target is ৳${widget.suggestedAmount.toStringAsFixed(0)} per member',
            ),
            validator: (value) {
              final amount = double.tryParse(value?.trim() ?? '');
              return amount == null || amount <= 0
                  ? 'Enter a valid amount.'
                  : null;
            },
          ),
          SizedBox(height: 18.h),
          const _Label(text: 'PAYMENT METHOD'),
          SizedBox(height: 8.h),
          ClubPaymentMethodSelector(
            value: _paymentMethod,
            onChanged: (value) => setState(() => _paymentMethod = value),
          ),
          SizedBox(height: 18.h),
          TextFormField(
            controller: _noteController,
            maxLines: 3,
            maxLength: 240,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.sticky_note_2_rounded),
            ),
          ),
          SizedBox(height: 12.h),
          FilledButton.icon(
            onPressed: widget.isSubmitting ? null : _submit,
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            icon: widget.isSubmitting
                ? SizedBox(
                    width: 18.r,
                    height: 18.r,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    widget.isAdmin
                        ? Icons.verified_rounded
                        : Icons.send_rounded,
                  ),
            label: Text(
              widget.isAdmin ? 'Save paid entry' : 'Submit pending entry',
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: MyString.poppinsBold,
        fontSize: 9.sp,
        letterSpacing: 1.1,
        color: MyColor.primary,
      ),
    );
  }
}
