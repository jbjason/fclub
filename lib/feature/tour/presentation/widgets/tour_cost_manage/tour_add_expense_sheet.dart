import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/my_dialog.dart';
import 'package:fclub/feature/tour/data/expense_category.dart';
import 'package:fclub/feature/tour/data/model/tour_member_model.dart';
import 'package:fclub/feature/tour/presentation/provider/tour_provider.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_cost_manage/tour_all_beneficiaries_chip.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_cost_manage/tour_category_chip.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_cost_manage/tour_member_select_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

Future<void> showAddExpenseSheet(BuildContext context) {
  final tourProvider = context.read<TourProvider>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: tourProvider,
      child: const AddExpenseBottomSheet(),
    ),
  );
}

class AddExpenseBottomSheet extends StatefulWidget {
  const AddExpenseBottomSheet({super.key});

  @override
  State<AddExpenseBottomSheet> createState() => _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends State<AddExpenseBottomSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  ExpenseCategory _category = ExpenseCategory.food;
  String? _paidByMemberId;
  bool _allBenefit = true;
  final Set<String> _beneficiaryIds = {};
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _toggleAllBenefit() {
    setState(() {
      _allBenefit = true;
      _beneficiaryIds.clear();
    });
  }

  void _toggleBeneficiary(String memberId) {
    setState(() {
      _allBenefit = false;
      if (_beneficiaryIds.contains(memberId)) {
        _beneficiaryIds.remove(memberId);
      } else {
        _beneficiaryIds.add(memberId);
      }
    });
  }

  Future<void> _submit(List<TourMemberModel> members) async {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;

    if (title.isEmpty) {
      MyDialog().showFailedToast(msg: 'enter_title'.tr(), context: context);
      return;
    }
    if (amount <= 0) {
      MyDialog().showFailedToast(msg: 'enter_valid_amount'.tr(), context: context);
      return;
    }
    if (_paidByMemberId == null) {
      MyDialog().showFailedToast(msg: 'select_who_paid'.tr(), context: context);
      return;
    }
    if (!_allBenefit && _beneficiaryIds.isEmpty) {
      MyDialog().showFailedToast(
        msg: 'select_beneficiary'.tr(),
        context: context,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await context.read<TourProvider>().addExpense(
      title: title,
      amount: amount,
      paidByMemberId: _paidByMemberId!,
      beneficiaryMemberIds: _allBenefit ? [] : _beneficiaryIds.toList(),
      category: _category,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final members = context.watch<TourProvider>().members;
    _paidByMemberId ??= members.isNotEmpty ? members.first.id : null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Text('add_expense'.tr(), style: _titleStyle),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: colorScheme.onSurfaceVariant, size: 22.r),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'enter_title'.tr()),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'amount'.tr()),
              ),
              SizedBox(height: 16.h),
              Text('category'.tr(), style: _labelStyle),
              SizedBox(height: 8.h),
              SizedBox(
                height: 64.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ExpenseCategory.values
                      .map(
                        (category) => TourCategoryChip(
                          category: category,
                          isSelected: _category == category,
                          onTap: () => setState(() => _category = category),
                        ),
                      )
                      .toList(),
                ),
              ),
              SizedBox(height: 16.h),
              Text('paid_by'.tr(), style: _labelStyle),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: members.map((member) {
                  return TourMemberSelectChip(
                    member: member,
                    isSelected: _paidByMemberId == member.id,
                    onTap: () => setState(() => _paidByMemberId = member.id),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.h),
              Text('who_benefited'.tr(), style: _labelStyle),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: [
                  TourAllBeneficiariesChip(
                    isSelected: _allBenefit,
                    onTap: _toggleAllBenefit,
                  ),
                  ...members.map((member) {
                    return TourMemberSelectChip(
                      member: member,
                      isSelected: !_allBenefit && _beneficiaryIds.contains(member.id),
                      onTap: () => _toggleBeneficiary(member.id),
                    );
                  }),
                ],
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(labelText: 'note_optional'.tr()),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isSubmitting
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: () => _submit(members),
                          child: Text('add_expense'.tr()),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle get _titleStyle => TextStyle(
    fontFamily: MyString.poppinsBold,
    fontWeight: FontWeight.w700,
    fontSize: 18.sp,
    color: Theme.of(context).colorScheme.onSurface,
  );

  TextStyle get _labelStyle => TextStyle(
    fontFamily: MyString.poppinsMedium,
    fontWeight: FontWeight.w600,
    fontSize: 13.sp,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );
}
