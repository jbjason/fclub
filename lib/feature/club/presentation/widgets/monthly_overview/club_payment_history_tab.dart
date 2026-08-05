import 'package:fclub/feature/club/data/model/club_payment.dart';
import 'package:fclub/feature/club/data/model/club_payment_filter.dart';
import 'package:fclub/feature/club/presentation/provider/club_provider.dart';
import 'package:fclub/feature/club/presentation/widgets/monthly_overview/club_payment_card.dart';
import 'package:fclub/feature/club/presentation/widgets/monthly_overview/club_payment_filter_bar.dart';
import 'package:fclub/feature/club/presentation/widgets/shared/club_state_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ClubPaymentHistoryTab extends StatelessWidget {
  const ClubPaymentHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClubProvider>();
    return Column(
      children: [
        ClubPaymentFilterBar(
          filter: provider.filter,
          members: provider.members,
          onChanged: provider.setFilter,
        ),
        Expanded(
          child: provider.isFiltering
              ? const Center(child: CircularProgressIndicator())
              : provider.filteredPayments.isEmpty
              ? ClubStatePanel(
                  icon: provider.filter.isEmpty
                      ? Icons.receipt_long_rounded
                      : Icons.filter_alt_off_rounded,
                  title: provider.filter.isEmpty
                      ? 'No payments yet'
                      : 'No matching payments',
                  message: provider.filter.isEmpty
                      ? 'Use Add Entry to create the first Firestore payment.'
                      : 'Try changing or clearing the active API filters.',
                  actionLabel: provider.filter.isEmpty ? null : 'Clear filters',
                  onAction: provider.filter.isEmpty
                      ? null
                      : () => provider.setFilter(const ClubPaymentFilter()),
                )
              : RefreshIndicator(
                  onRefresh: () => provider.initialize(force: true),
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 100.h),
                    itemCount: provider.filteredPayments.length,
                    itemBuilder: (context, index) {
                      final payment = provider.filteredPayments[index];
                      return ClubPaymentCard(
                        payment: payment,
                        member: provider.memberById(payment.userId),
                        isAdmin: provider.isAdmin,
                        onStatusChanged: (status) =>
                            _updateStatus(context, payment, status),
                        onDelete: () => _confirmDelete(context, payment),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    ClubPayment payment,
    PaymentStatus status,
  ) async {
    try {
      await context.read<ClubProvider>().updatePaymentStatus(
        payment.id,
        status,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment marked ${status.value}.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<ClubProvider>().actionError ?? '$error'),
        ),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, ClubPayment payment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete payment?'),
        content: const Text('This Firestore payment record will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await context.read<ClubProvider>().deletePayment(payment.id);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<ClubProvider>().actionError ?? '$error'),
        ),
      );
    }
  }
}
