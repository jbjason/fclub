import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_member_model.dart';
import 'package:fclub/feature/kurbani/presentation/provider/kurbani_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class KurbaniAddExpenseSheet extends StatefulWidget {
  const KurbaniAddExpenseSheet({super.key});

  @override
  State<KurbaniAddExpenseSheet> createState() => _KurbaniAddExpenseSheetState();
}

class _KurbaniAddExpenseSheetState extends State<KurbaniAddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedMemberId;
  bool _isLoading = false;

  static const _headerGradient = LinearGradient(
    colors: [Color(0xFF064E3B), Color(0xFF1E1B4B)],
  );

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select who paid')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await context.read<KurbaniProvider>().addExpense(
          title: _titleController.text.trim(),
          amount: double.parse(_amountController.text.trim()),
          paidByMemberId: _selectedMemberId!,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final members = context.read<KurbaniProvider>().members;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          // Header
          Container(
            margin: EdgeInsets.all(16.w),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: _headerGradient,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Icon(Icons.add_card_rounded, color: Colors.white, size: 22.r),
                SizedBox(width: 10.w),
                Text(
                  'Add Expense',
                  style: TextStyle(
                    fontFamily: MyString.poppinsBold,
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          // Form
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildField(
                    controller: _titleController,
                    label: 'Title',
                    hint: 'e.g. Cow Purchase',
                    icon: Icons.label_outline_rounded,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: 12.h),
                  _buildField(
                    controller: _amountController,
                    label: 'Amount (৳)',
                    hint: '0',
                    icon: Icons.attach_money_rounded,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (double.tryParse(v.trim()) == null) return 'Invalid';
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  _buildMemberDropdown(members),
                  SizedBox(height: 12.h),
                  _buildField(
                    controller: _noteController,
                    label: 'Note (optional)',
                    hint: 'Any detail…',
                    icon: Icons.notes_rounded,
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF064E3B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20.r,
                              height: 20.r,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Save Expense',
                              style: TextStyle(
                                fontFamily: MyString.poppinsBold,
                                fontSize: 14.sp,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18.r),
        filled: true,
        fillColor: const Color(0xFFF8F7FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF064E3B), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildMemberDropdown(List<KurbaniMemberModel> members) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedMemberId,
      hint: const Text('Who paid?'),
      items: members
          .map(
            (m) => DropdownMenuItem(
              value: m.id,
              child: Text(m.name),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => _selectedMemberId = v),
      decoration: InputDecoration(
        labelText: 'Paid By',
        prefixIcon: Icon(Icons.person_outline_rounded, size: 18.r),
        filled: true,
        fillColor: const Color(0xFFF8F7FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF064E3B), width: 1.5),
        ),
      ),
    );
  }
}
