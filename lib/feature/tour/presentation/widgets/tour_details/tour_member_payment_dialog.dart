import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/tour/data/models/tour_participant.dart';
import 'package:fclub/feature/tour/presentation/widgets/shared/tour_palette.dart';
import 'package:flutter/material.dart';

class TourMemberPaymentDialog extends StatefulWidget {
  const TourMemberPaymentDialog({super.key, required this.member});

  final TourParticipant member;

  @override
  State<TourMemberPaymentDialog> createState() =>
      _TourMemberPaymentDialogState();
}

class _TourMemberPaymentDialogState extends State<TourMemberPaymentDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.member.paidToManager == 0
        ? ''
        : widget.member.paidToManager.toStringAsFixed(0),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(
        Icons.account_balance_wallet_rounded,
        color: TourPalette.lagoon,
      ),
      title: Text(
        widget.member.name,
        style: const TextStyle(fontFamily: MyString.poppinsBold),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          prefixText: '৳ ',
          labelText: 'tour_paid_to_manager'.tr(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        FilledButton(
          onPressed: () {
            final amount = double.tryParse(_controller.text.trim());
            if (amount != null && amount >= 0) Navigator.pop(context, amount);
          },
          child: Text('save'.tr()),
        ),
      ],
    );
  }
}
