import 'package:fclub/feature/club/presentation/provider/club_provider.dart';
import 'package:fclub/feature/club/presentation/widgets/add_entry/club_payment_form.dart';
import 'package:fclub/feature/club/presentation/widgets/member_management/club_member_management_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClubAddEntryScreen extends StatelessWidget {
  const ClubAddEntryScreen({super.key, this.initialMonth});

  final DateTime? initialMonth;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClubProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(provider.isAdmin ? 'Record payment' : 'Submit payment'),
      ),
      body: ClubPaymentForm(
        members: provider.members,
        currentMember: provider.currentMember,
        isAdmin: provider.isAdmin,
        isSubmitting: provider.isSubmitting,
        initialMonth: initialMonth,
        onManageMembers: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const ClubMemberManagementSheet(),
        ),
        onSubmit:
            ({
              required memberId,
              required amount,
              required month,
              required paymentMethod,
              note,
            }) async {
              try {
                await context.read<ClubProvider>().submitPayment(
                  memberId: memberId,
                  amount: amount,
                  month: month,
                  paymentMethod: paymentMethod,
                  note: note,
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      provider.isAdmin
                          ? 'Paid entry saved.'
                          : 'Payment submitted for admin review.',
                    ),
                  ),
                );
              } catch (error) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(provider.actionError ?? '$error')),
                );
              }
            },
      ),
    );
  }
}
