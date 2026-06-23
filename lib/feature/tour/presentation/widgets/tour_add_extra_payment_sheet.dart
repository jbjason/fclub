import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/my_dialog.dart';
import 'package:fclub/feature/tour/presentation/provider/tour_provider.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

Future<void> showAddExtraPaymentSheet(BuildContext context) {
  final tourProvider = context.read<TourProvider>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: tourProvider,
      child: const AddExtraPaymentBottomSheet(),
    ),
  );
}

class AddExtraPaymentBottomSheet extends StatefulWidget {
  const AddExtraPaymentBottomSheet({super.key});

  @override
  State<AddExtraPaymentBottomSheet> createState() =>
      _AddExtraPaymentBottomSheetState();
}

class _AddExtraPaymentBottomSheetState
    extends State<AddExtraPaymentBottomSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _memberId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;

    if (_memberId == null) {
      MyDialog().showFailedToast(msg: 'Select a member.', context: context);
      return;
    }
    if (amount <= 0) {
      MyDialog().showFailedToast(msg: 'Enter a valid amount.', context: context);
      return;
    }

    setState(() => _isSubmitting = true);
    await context.read<TourProvider>().addExtraPayment(
      memberId: _memberId!,
      amount: amount,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final members = context.watch<TourProvider>().members;
    _memberId ??= members.isNotEmpty ? members.first.id : null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: MyColor.surfaceContainerLowest,
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
                    color: MyColor.outlineVariant,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Add Extra Payment',
                style: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp,
                  color: MyColor.onSurface,
                ),
              ),
              SizedBox(height: 16.h),
              Text('Member', style: _labelStyle),
              SizedBox(height: 8.h),
              SizedBox(
                height: 72.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: members.length,
                  separatorBuilder: (_, _) => SizedBox(width: 12.w),
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final isSelected = _memberId == member.id;
                    return GestureDetector(
                      onTap: () => setState(() => _memberId = member.id),
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.all(isSelected ? 3.w : 0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? MyColor.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: TourMemberAvatar(
                              name: member.name,
                              colorIndex: member.avatarColorIndex,
                              radius: 18.r,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            member.name,
                            style: TextStyle(fontSize: 11.sp),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              SizedBox(height: 12.h),
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
                          onPressed: _submit,
                          child: const Text('Add Payment'),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle get _labelStyle => TextStyle(
    fontFamily: MyString.poppinsMedium,
    fontWeight: FontWeight.w600,
    fontSize: 13.sp,
    color: MyColor.onSurfaceVariant,
  );
}
