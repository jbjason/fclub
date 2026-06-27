import 'package:fclub/core/services/contacts/global_contacts_provider.dart';
import 'package:fclub/feature/club/data/model/payment_entry.dart';
import 'package:fclub/feature/club/data/model/payment_status.dart';
import 'package:fclub/feature/club/presentation/provider/club_provider.dart';
import 'package:fclub/feature/club/presentation/widgets/club_member_dropdown.dart';
import 'package:fclub/feature/club/presentation/widgets/club_month_dropdown.dart';
import 'package:fclub/feature/club/presentation/widgets/club_status_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Fields collected by [ClubEntryForm] on submit.
typedef ClubEntryFormSubmit = Future<void> Function({
  required String contactId,
  required DateTime month,
  required double amount,
  required PaymentStatus status,
  required DateTime date,
  String? note,
});

/// Shared Add/Edit form. [initialEntry] prefills every field when editing;
/// leave it null to start blank for a new entry. [initialMonth] additionally
/// pre-selects a month for a *new* entry (ignored when [initialEntry] is
/// set) — used when adding an entry from within a specific month's view.
class ClubEntryForm extends StatefulWidget {
  const ClubEntryForm({
    super.key,
    this.initialEntry,
    this.initialMonth,
    required this.submitLabel,
    required this.onSubmit,
  });

  final PaymentEntry? initialEntry;
  final DateTime? initialMonth;
  final String submitLabel;
  final ClubEntryFormSubmit onSubmit;

  @override
  State<ClubEntryForm> createState() => _ClubEntryFormState();
}

class _ClubEntryFormState extends State<ClubEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _contactId;
  DateTime? _month;
  PaymentStatus _status = PaymentStatus.paid;
  DateTime _date = DateTime.now();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final entry = widget.initialEntry;
    if (entry != null) {
      _contactId = entry.contactId;
      _month = entry.month;
      _status = entry.status;
      _date = entry.date;
      _amountController.text = entry.amount.toStringAsFixed(0);
      _noteController.text = entry.note ?? '';
    } else {
      final now = DateTime.now();
      _month = widget.initialMonth ?? DateTime(now.year, now.month, 1);
      _amountController.text =
          ClubProvider.monthlyContribution.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
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
    if (_contactId == null || _month == null) return;

    setState(() => _isSubmitting = true);
    await widget.onSubmit(
      contactId: _contactId!,
      month: _month!,
      amount: double.tryParse(_amountController.text.trim()) ?? 0,
      status: _status,
      date: _date,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final contacts = context.watch<GlobalContactsProvider>().contacts;
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          ClubMemberDropdown(
            contacts: contacts,
            value: _contactId,
            onChanged: (value) => setState(() => _contactId = value),
          ),
          SizedBox(height: 16.h),
          ClubMonthDropdown(
            value: _month,
            onChanged: (value) => setState(() => _month = value),
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
          Text('Status', style: textTheme.labelLarge),
          SizedBox(height: 8.h),
          ClubStatusSelector(
            selected: _status,
            onChanged: (status) => setState(() => _status = status),
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
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(widget.submitLabel),
            ),
          ),
        ],
      ),
    );
  }
}
