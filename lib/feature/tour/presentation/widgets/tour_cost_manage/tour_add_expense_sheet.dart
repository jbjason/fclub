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
      MyDialog().showFailedToast(msg: 'Enter a title.', context: context);
      return;
    }
    if (amount <= 0) {
      MyDialog().showFailedToast(msg: 'Enter a valid amount.', context: context);
      return;
    }
    if (_paidByMemberId == null) {
      MyDialog().showFailedToast(msg: 'Select who paid.', context: context);
      return;
    }
    if (!_allBenefit && _beneficiaryIds.isEmpty) {
      MyDialog().showFailedToast(
        msg: 'Select at least one beneficiary.',
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
              SizedBox(height: 16.h),
              Text('Add Expense', style: _titleStyle),
              SizedBox(height: 16.h),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              SizedBox(height: 16.h),
              Text('Category', style: _labelStyle),
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
              Text('Paid by', style: _labelStyle),
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
              Text('Who benefited?', style: _labelStyle),
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
                decoration: const InputDecoration(labelText: 'Note (optional)'),
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
                          child: const Text('Add Expense'),
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
