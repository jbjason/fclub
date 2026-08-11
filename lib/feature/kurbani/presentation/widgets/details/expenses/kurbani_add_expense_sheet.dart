import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/feature/kurbani/presentation/provider/kurbani_event_provider.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_sheet_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class KurbaniAddExpenseSheet extends StatefulWidget {
  const KurbaniAddExpenseSheet({super.key});

  @override
  State<KurbaniAddExpenseSheet> createState() => _KurbaniAddExpenseSheetState();
}

class _KurbaniAddExpenseSheetState extends State<KurbaniAddExpenseSheet> {
  static const _allMembersPayer = '__all_members__';

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _payerId;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_payerId == null) {
      _showError('kurbani_error_choose_payer');
      return;
    }
    try {
      await context.read<KurbaniEventProvider>().addExpense(
        title: _titleController.text,
        amount: double.parse(_amountController.text.trim()),
        paidByMemberId: _payerId == _allMembersPayer ? null : _payerId,
        paidByAllMembers: _payerId == _allMembersPayer,
        note: _noteController.text,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      _showError(
        context.read<KurbaniEventProvider>().actionError ??
            'kurbani_error_unknown',
      );
    }
  }

  void _showError(String key) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(key.tr())));

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KurbaniEventProvider>();
    final colors = Theme.of(context).colorScheme;
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: inset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .88,
        ),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            KurbaniSheetHeader(
              kicker: 'kurbani_expense_kicker'.tr(),
              title: 'add_expense'.tr(),
              icon: Icons.receipt_long_rounded,
              accent: KurbaniPalette.cyan,
            ),
            Flexible(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'kurbani_expense_title'.tr(),
                          hintText: 'kurbani_expense_title_hint'.tr(),
                          prefixIcon: const Icon(Icons.sell_outlined),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'kurbani_required'.tr()
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'kurbani_amount'.tr(),
                          prefixIcon: const Icon(Icons.payments_outlined),
                          prefixText: '৳ ',
                        ),
                        validator: (value) =>
                            (double.tryParse(value?.trim() ?? '') ?? 0) <= 0
                            ? 'kurbani_valid_amount'.tr()
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _payerId,
                        decoration: InputDecoration(
                          labelText: 'kurbani_paid_by_label'.tr(),
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: _allMembersPayer,
                            child: Text('kurbani_all_members_shared'.tr()),
                          ),
                          ...provider.participants.map(
                            (participant) => DropdownMenuItem(
                              value: participant.id,
                              child: Text(participant.username),
                            ),
                          ),
                        ],
                        onChanged: (value) => setState(() => _payerId = value),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _noteController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'kurbani_note_optional'.tr(),
                          prefixIcon: const Icon(Icons.notes_rounded),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: provider.isSubmitting ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: KurbaniPalette.cyan,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          icon: provider.isSubmitting
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.add_card_rounded),
                          label: Text('kurbani_save_expense'.tr()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
