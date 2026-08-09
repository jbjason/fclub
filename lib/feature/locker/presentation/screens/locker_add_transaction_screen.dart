import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/widgets/feature_ambient_background.dart';
import 'package:fclub/feature/locker/presentation/provider/locker_provider.dart';
import 'package:fclub/feature/locker/presentation/widgets/add_transaction/locker_transaction_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LockerAddTransactionScreen extends StatelessWidget {
  const LockerAddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LockerProvider>();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: .92),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('locker_add_transaction'.tr()),
            Text(
              'locker_ledger_kicker'.tr(),
              style: TextStyle(
                color: MyColor.secondary,
                fontFamily: MyString.rubikMedium,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: FeatureAmbientBackground(
          accent: MyColor.secondary,
          secondaryAccent: MyColor.primary,
          child: LockerTransactionForm(
            participants: provider.participants,
            currentParticipant: provider.currentParticipant,
            isAdmin: provider.isAdmin,
            isSubmitting: provider.isSubmitting,
            onSubmit:
                ({
                  required type,
                  required amount,
                  required participantId,
                  note,
                }) async {
                  try {
                    await context.read<LockerProvider>().submitTransaction(
                      type: type,
                      amount: amount,
                      participantId: participantId,
                      note: note,
                    );
                    if (context.mounted) Navigator.pop(context);
                  } catch (error) {
                    if (!context.mounted) return;
                    final message = provider.actionError ?? '$error';
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  }
                },
          ),
        ),
      ),
    );
  }
}
