import 'package:fclub/core/services/contacts/global_contacts_provider.dart';
import 'package:fclub/feature/tour/presentation/provider/tour_provider.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_new_tour_step_one.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_new_tour_step_two.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_sheet_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TourNewTourSheet extends StatefulWidget {
  const TourNewTourSheet({super.key, required this.provider});
  final TourProvider provider;

  @override
  State<TourNewTourSheet> createState() => _TourNewTourSheetState();
}

class _TourNewTourSheetState extends State<TourNewTourSheet> {
  int _step = 0;

  // Step 1
  final _tourNameCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController(text: '20000');
  final _formKey = GlobalKey<FormState>();

  // Step 2
  final Set<String> _selectedIds = {};

  @override
  void dispose() {
    _tourNameCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  void _toggleSelected(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _submit() async {
    final budget = double.tryParse(_budgetCtrl.text.trim()) ?? 20000;
    await widget.provider.createSession(
      tourName: _tourNameCtrl.text.trim(),
      decidedBudget: budget,
      selectedContactIds: _selectedIds.toList(),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final globalContacts = context.watch<GlobalContactsProvider>();

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 4.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2.r)),
              ),
            ),
            TourSheetHeader(
              step: _step,
              onBack:
                  _step == 1 ? () => setState(() => _step = 0) : null,
            ),
            if (_step == 0)
              TourNewTourStepOne(
                formKey: _formKey,
                tourNameCtrl: _tourNameCtrl,
                budgetCtrl: _budgetCtrl,
                onNext: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _step = 1);
                  }
                },
              )
            else
              TourNewTourStepTwo(
                contacts: globalContacts.contacts,
                meId: globalContacts.meContact?.id,
                selectedIds: _selectedIds,
                onToggle: _toggleSelected,
                onSubmit: _submit,
              ),
          ],
        ),
      ),
    );
  }
}
