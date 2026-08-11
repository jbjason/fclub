import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/tour/presentation/widgets/shared/tour_palette.dart';
import 'package:flutter/material.dart';

class TourBudgetDialog extends StatefulWidget {
  const TourBudgetDialog({super.key, required this.initialValue});

  final double initialValue;

  @override
  State<TourBudgetDialog> createState() => _TourBudgetDialogState();
}

class _TourBudgetDialogState extends State<TourBudgetDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue.toStringAsFixed(0),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.savings_rounded, color: TourPalette.sunset),
      title: Text(
        'tour_total_budget'.tr(),
        style: const TextStyle(fontFamily: MyString.poppinsBold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(prefixText: '৳ '),
          ),
          const SizedBox(height: 12),
          Text(
            'tour_budget_update_hint'.tr(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        FilledButton(
          onPressed: () {
            final amount = double.tryParse(_controller.text.trim());
            if (amount != null && amount > 0) Navigator.pop(context, amount);
          },
          child: Text('save'.tr()),
        ),
      ],
    );
  }
}
