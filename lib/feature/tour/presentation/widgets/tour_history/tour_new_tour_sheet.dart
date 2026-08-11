import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/feature/tour/presentation/provider/tour_provider.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_history/tour_new_tour_step_one.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_history/tour_new_tour_step_two.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_history/tour_sheet_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TourNewTourSheet extends StatefulWidget {
  const TourNewTourSheet({super.key});

  @override
  State<TourNewTourSheet> createState() => _TourNewTourSheetState();
}

class _TourNewTourSheetState extends State<TourNewTourSheet> {
  final _tourNameController = TextEditingController();
  final _budgetController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final Set<String> _selectedIds = {};
  int _step = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _tourNameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _toggleSelected(String id) {
    setState(() {
      _selectedIds.contains(id)
          ? _selectedIds.remove(id)
          : _selectedIds.add(id);
    });
  }

  Future<void> _submit() async {
    final provider = context.read<TourProvider>();
    setState(() => _isSubmitting = true);
    try {
      final event = await provider.createEvent(
        tourName: _tourNameController.text,
        decidedBudget: double.parse(_budgetController.text.trim()),
        participantIds: _selectedIds,
      );
      if (mounted) Navigator.pop(context, event);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text((provider.actionError ?? 'tour_error_unknown').tr()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<TourProvider>();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 10.h, bottom: 4.h),
                width: 42.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            TourSheetHeader(
              step: _step,
              onBack: _step == 1 ? () => setState(() => _step = 0) : null,
            ),
            if (_step == 0)
              TourNewTourStepOne(
                formKey: _formKey,
                tourNameCtrl: _tourNameController,
                budgetCtrl: _budgetController,
                onNext: () {
                  if (_formKey.currentState?.validate() == true) {
                    setState(() => _step = 1);
                  }
                },
              )
            else
              TourNewTourStepTwo(
                members: provider.groupMembers,
                currentUserId: provider.currentUserId,
                selectedIds: _selectedIds,
                isSubmitting: _isSubmitting,
                onToggle: _toggleSelected,
                onSubmit: _submit,
              ),
          ],
        ),
      ),
    );
  }
}
