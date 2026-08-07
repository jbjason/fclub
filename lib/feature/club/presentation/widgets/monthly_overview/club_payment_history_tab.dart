import 'package:fclub/feature/club/data/model/club_payment_filter.dart';
import 'package:fclub/feature/club/presentation/provider/club_provider.dart';
import 'package:fclub/feature/club/presentation/screens/club_details/club_payment_details_screen.dart';
import 'package:fclub/feature/club/presentation/widgets/monthly_overview/club_payment_card.dart';
import 'package:fclub/feature/club/presentation/widgets/monthly_overview/club_payment_filter_bar.dart';
import 'package:fclub/feature/club/presentation/widgets/shared/club_payment_review_actions.dart';
import 'package:fclub/feature/club/presentation/widgets/shared/club_state_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ClubPaymentHistoryTab extends StatelessWidget {
  const ClubPaymentHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClubProvider>();
    final visiblePayments = provider.visibleFilteredPayments;
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
              : visiblePayments.isEmpty
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
                    itemCount: visiblePayments.length,
                    itemBuilder: (context, index) {
                      final payment = visiblePayments[index];
                      return ClubPaymentCard(
                        payment: payment,
                        member: provider.memberById(payment.userId),
                        isAdmin: provider.isAdmin,
                        onTap: () {
                          final member = provider.memberById(payment.userId);
                          Navigator.push<void>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ClubPaymentDetailsScreen(
                                userId: payment.userId,
                                fallbackName: member?.name,
                                fallbackEmail: member?.email,
                              ),
                            ),
                          );
                        },
                        onStatusChanged: (status) =>
                            ClubPaymentReviewActions.updateStatus(
                              context,
                              payment,
                              status,
                            ),
                        onDelete: () => ClubPaymentReviewActions.confirmDelete(
                          context,
                          payment,
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
