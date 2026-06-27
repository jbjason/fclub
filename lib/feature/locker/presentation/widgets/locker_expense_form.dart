import 'package:fclub/feature/locker/data/model/locker_expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

/// Fields collected by [LockerExpenseForm] on submit.
typedef LockerExpenseFormSubmit = Future<void> Function({
  required String title,
  required double amount,
  required DateTime date,
  String? note,
});

/// Shared Add/Edit form. [initialExpense] prefills every field when editing;
/// leave it null to start blank for a new expense.
class LockerExpenseForm extends StatefulWidget {
  const LockerExpenseForm({
    super.key,
    this.initialExpense,
    required this.submitLabel,
    required this.onSubmit,
  });

  final LockerExpense? initialExpense;
  final String submitLabel;
  final LockerExpenseFormSubmit onSubmit;

  @override
  State<LockerExpenseForm> createState() => _LockerExpenseFormState();
}

class _LockerExpenseFormState extends State<LockerExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _date = DateTime.now();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final expense = widget.initialExpense;
    if (expense != null) {
      _titleController.text = expense.title;
      _amountController.text = expense.amount.toStringAsFixed(0);
      _noteController.text = expense.note ?? '';
      _date = expense.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await widget.onSubmit(
      title: _titleController.text.trim(),
      amount: double.tryParse(_amountController.text.trim()) ?? 0,
      date: _date,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Required' : null,
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Required';
              final parsed = double.tryParse(value.trim());
              if (parsed == null || parsed <= 0) return 'Enter a valid amount';
              return null;
            },
          ),
          SizedBox(height: 16.h),
          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date',
                suffixIcon: Icon(Icons.calendar_today_rounded),
              ),
              child: Text(DateFormat('d MMM yyyy').format(_date)),
            ),
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'Note (optional)'),
            maxLines: 2,
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(widget.submitLabel),
            ),
          ),
        ],
      ),
    );
  }
}
