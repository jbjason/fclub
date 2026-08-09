import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/locker/data/models/locker_participant.dart';
import 'package:fclub/feature/locker/data/models/locker_transaction.dart';
import 'package:fclub/feature/locker/presentation/widgets/locker_card_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef LockerTransactionSubmit =
    Future<void> Function({
      required LockerTransactionType type,
      required double amount,
      required String? participantId,
      String? note,
    });

class LockerTransactionForm extends StatefulWidget {
  const LockerTransactionForm({
    super.key,
    required this.participants,
    required this.currentParticipant,
    required this.isAdmin,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final List<LockerParticipant> participants;
  final LockerParticipant? currentParticipant;
  final bool isAdmin;
  final bool isSubmitting;
  final LockerTransactionSubmit onSubmit;

  @override
  State<LockerTransactionForm> createState() => _LockerTransactionFormState();
}

class _LockerTransactionFormState extends State<LockerTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  LockerTransactionType _type = LockerTransactionType.expense;
  String? _participantId;

  Color get _accent => _type == LockerTransactionType.expense
      ? MyColor.tertiary
      : MyColor.success;

  @override
  void initState() {
    super.initState();
    _participantId =
        widget.currentParticipant?.id ??
        (widget.participants.isEmpty ? null : widget.participants.first.id);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await widget.onSubmit(
      type: _type,
      amount: double.parse(_amountController.text.trim()),
      participantId: _participantId,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 34.h),
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: _TransactionHero(key: ValueKey(_type), type: _type),
          ),
          SizedBox(height: 19.h),
          _SectionLabel(
            label: 'locker_choose_transaction_type'.tr(),
            accent: _accent,
          ),
          SizedBox(height: 9.h),
          Row(
            children: [
              Expanded(
                child: _TypeChoice(
                  key: const Key('locker-expense-option'),
                  label: 'locker_transaction_expense'.tr(),
                  caption: 'locker_money_out'.tr(),
                  icon: Icons.north_east_rounded,
                  accent: MyColor.tertiary,
                  selected: _type == LockerTransactionType.expense,
                  onTap: () =>
                      setState(() => _type = LockerTransactionType.expense),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _TypeChoice(
                  key: const Key('locker-contribution-option'),
                  label: 'locker_transaction_contribution'.tr(),
                  caption: 'locker_money_in'.tr(),
                  icon: Icons.south_west_rounded,
                  accent: MyColor.success,
                  selected: _type == LockerTransactionType.contribution,
                  onTap: () => setState(
                    () => _type = LockerTransactionType.contribution,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          LockerCardShell(
            accent: _accent,
            borderRadius: BorderRadius.circular(24.r),
            padding: EdgeInsets.all(17.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(
                  label: 'locker_transaction_details'.tr(),
                  accent: _accent,
                ),
                SizedBox(height: 15.h),
                if (widget.isAdmin)
                  DropdownButtonFormField<String>(
                    initialValue: _participantId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'locker_participant'.tr(),
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                    ),
                    items: widget.participants
                        .map(
                          (participant) => DropdownMenuItem(
                            value: participant.id,
                            child: Text(
                              participant.username,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) =>
                        setState(() => _participantId = value),
                    validator: (value) => value == null
                        ? 'locker_choose_participant_error'.tr()
                        : null,
                  )
                else
                  _CurrentParticipantCard(
                    name:
                        widget.currentParticipant?.username ??
                        'locker_participant'.tr(),
                  ),
                SizedBox(height: 14.h),
                TextFormField(
                  key: const Key('locker-transaction-amount'),
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: 'locker_amount'.tr(),
                    prefixIcon: const Icon(Icons.payments_outlined),
                    prefixText: '৳ ',
                  ),
                  validator: (value) {
                    final amount = double.tryParse(value?.trim() ?? '');
                    return amount == null || amount <= 0
                        ? 'locker_valid_amount_error'.tr()
                        : null;
                  },
                ),
                SizedBox(height: 14.h),
                TextFormField(
                  controller: _noteController,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: 240,
                  decoration: InputDecoration(
                    labelText: 'locker_note_optional'.tr(),
                    alignLabelWithHint: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 48),
                      child: Icon(Icons.edit_note_rounded),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const Key('locker-transaction-submit'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    onPressed: widget.isSubmitting ? null : _submit,
                    icon: widget.isSubmitting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
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
                      widget.isAdmin
                          ? 'locker_save_approved'.tr()
                          : 'locker_submit_review'.tr(),
                      style: TextStyle(
                        fontFamily: MyString.poppinsMedium,
                        fontWeight: FontWeight.w700,
                      ),
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
}

class _TransactionHero extends StatelessWidget {
  const _TransactionHero({super.key, required this.type});

  final LockerTransactionType type;

  @override
  Widget build(BuildContext context) {
    final isExpense = type == LockerTransactionType.expense;
    final accent = isExpense ? MyColor.tertiary : MyColor.success;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27.r),
        gradient: LinearGradient(
          colors: isExpense
              ? const [Color(0xFF4A1029), Color(0xFF9D174D), Color(0xFF6D28D9)]
              : const [Color(0xFF063A35), Color(0xFF087E70), Color(0xFF3946B7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: .25),
            blurRadius: 28,
            spreadRadius: -8,
            offset: const Offset(0, 13),
          ),
        ],
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            end: -2.w,
            bottom: -16.h,
            child: Icon(
              isExpense ? Icons.receipt_long_rounded : Icons.savings_rounded,
              color: Colors.white.withValues(alpha: .08),
              size: 94.r,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .16),
                  ),
                ),
                child: Text(
                  (isExpense
                          ? 'locker_new_expense_kicker'
                          : 'locker_new_contribution_kicker')
                      .tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: MyString.rubikMedium,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              SizedBox(height: 13.h),
              Text(
                (isExpense
                        ? 'locker_expense_headline'
                        : 'locker_contribution_headline')
                    .tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: MyString.poppinsBold,
                  fontSize: 21.sp,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              SizedBox(height: 4.h),
              SizedBox(
                width: 245.w,
                child: Text(
                  (isExpense
                          ? 'locker_expense_description'
                          : 'locker_contribution_description')
                      .tr(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .7),
                    fontFamily: MyString.rubikRegular,
                    fontSize: 9.5.sp,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeChoice extends StatelessWidget {
  const _TypeChoice({
    super.key,
    required this.label,
    required this.caption,
    required this.icon,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String caption;
  final IconData icon;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 190),
          padding: EdgeInsets.all(13.w),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: .11)
                : colors.surfaceContainerLowest.withValues(alpha: .84),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: .7)
                  : colors.outlineVariant.withValues(alpha: .45),
              width: selected ? 1.4 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: .14),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: accent, size: 18.r),
              ),
              SizedBox(width: 9.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? accent : colors.onSurface,
                        fontFamily: MyString.poppinsMedium,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontFamily: MyString.rubikRegular,
                        fontSize: 8.sp,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: accent, size: 17.r),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrentParticipantCard extends StatelessWidget {
  const _CurrentParticipantCard({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: MyColor.secondary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: MyColor.secondary.withValues(alpha: .2)),
      ),
      child: Row(
        children: [
          Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              color: MyColor.secondary.withValues(alpha: .13),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: MyColor.secondary,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: MyString.poppinsMedium,
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'locker_submitted_for_you'.tr(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontFamily: MyString.rubikRegular,
                    fontSize: 8.5.sp,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.lock_rounded, color: MyColor.secondary, size: 18),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 14.h,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(width: 7.w),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: accent,
            fontFamily: MyString.poppinsBold,
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: .8,
          ),
        ),
      ],
    );
  }
}
