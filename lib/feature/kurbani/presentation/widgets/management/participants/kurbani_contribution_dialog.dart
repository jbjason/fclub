import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_participant.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:flutter/material.dart';

class KurbaniContributionResult {
  const KurbaniContributionResult({required this.amount, required this.status});

  final double amount;
  final KurbaniPaidStatus status;
}

Future<KurbaniContributionResult?> showKurbaniContributionDialog({
  required BuildContext context,
  required String title,
  required double amount,
  required KurbaniPaidStatus initialStatus,
  required bool allowStatus,
}) async {
  final controller = TextEditingController(
    text: amount <= 0 ? '' : amount.toStringAsFixed(0),
  );
  var status = initialStatus;
  final result = await showDialog<KurbaniContributionResult>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        icon: const Icon(Icons.savings_rounded, color: KurbaniPalette.emerald),
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'kurbani_contribution'.tr(),
                prefixText: '৳ ',
              ),
            ),
            if (allowStatus) ...[
              const SizedBox(height: 13),
              SegmentedButton<KurbaniPaidStatus>(
                segments: [
                  ButtonSegment(
                    value: KurbaniPaidStatus.pending,
                    label: Text('kurbani_pending'.tr()),
                  ),
                  ButtonSegment(
                    value: KurbaniPaidStatus.paid,
                    label: Text('kurbani_paid'.tr()),
                  ),
                ],
                selected: {status},
                onSelectionChanged: (value) =>
                    setDialogState(() => status = value.first),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim()) ?? 0;
              if (value <= 0) return;
              Navigator.pop(
                dialogContext,
                KurbaniContributionResult(amount: value, status: status),
              );
            },
            child: Text('save'.tr()),
          ),
        ],
      ),
    ),
  );
  controller.dispose();
  return result;
}
