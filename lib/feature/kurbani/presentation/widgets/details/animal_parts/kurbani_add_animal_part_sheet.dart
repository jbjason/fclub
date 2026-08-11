import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/feature/kurbani/presentation/extensions/kurbani_part_display_extension.dart';
import 'package:fclub/feature/kurbani/presentation/provider/kurbani_event_provider.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_sheet_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class KurbaniAddAnimalPartSheet extends StatefulWidget {
  const KurbaniAddAnimalPartSheet({super.key});

  @override
  State<KurbaniAddAnimalPartSheet> createState() =>
      _KurbaniAddAnimalPartSheetState();
}

class _KurbaniAddAnimalPartSheetState extends State<KurbaniAddAnimalPartSheet> {
  static const _partNames = [
    'meat',
    'bone',
    'liver',
    'ribs',
    'offal',
    'head',
    'feet',
  ];

  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _noteController = TextEditingController();
  String? _partName;
  String? _assignedToUid;

  @override
  void dispose() {
    _weightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_partName == null) {
      _showError('kurbani_error_choose_part');
      return;
    }
    try {
      await context.read<KurbaniEventProvider>().addAnimalPart(
        name: _partName!,
        weightKg: double.parse(_weightController.text.trim()),
        assignedToUid: _assignedToUid,
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
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .9,
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
              kicker: 'kurbani_part_kicker'.tr(),
              title: 'kurbani_add_part'.tr(),
              icon: Icons.set_meal_rounded,
            ),
            Flexible(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _partName,
                        decoration: InputDecoration(
                          labelText: 'kurbani_part_name'.tr(),
                          prefixIcon: const Icon(Icons.category_outlined),
                        ),
                        items: _partNames
                            .map(
                              (name) => DropdownMenuItem(
                                value: name,
                                child: Text(name.localizedKurbaniPartName),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) => setState(() => _partName = value),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'kurbani_weight'.tr(),
                          prefixIcon: const Icon(Icons.scale_rounded),
                          suffixText: 'kurbani_kg'.tr(),
                        ),
                        validator: (value) =>
                            (double.tryParse(value?.trim() ?? '') ?? 0) <= 0
                            ? 'kurbani_valid_weight'.tr()
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _assignedToUid,
                        decoration: InputDecoration(
                          labelText: 'kurbani_assign_optional'.tr(),
                          prefixIcon: const Icon(Icons.person_pin_outlined),
                        ),
                        items: provider.participants
                            .map(
                              (participant) => DropdownMenuItem(
                                value: participant.id,
                                child: Text(participant.username),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) =>
                            setState(() => _assignedToUid = value),
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
                            backgroundColor: KurbaniPalette.gold,
                            foregroundColor: KurbaniPalette.midnight,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          icon: provider.isSubmitting
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.add_rounded),
                          label: Text('kurbani_save_part'.tr()),
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
