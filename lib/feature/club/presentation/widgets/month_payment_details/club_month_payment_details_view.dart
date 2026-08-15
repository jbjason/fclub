import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/feature/club/data/model/club_member.dart';
import 'package:fclub/feature/club/data/model/club_month_payment_filter.dart';
import 'package:fclub/feature/club/data/model/club_payment.dart';
import 'package:fclub/feature/club/presentation/provider/club_month_payment_details_provider.dart';
import 'package:fclub/feature/club/presentation/provider/club_provider.dart';
import 'package:fclub/feature/club/presentation/screens/club_details/club_payment_details_screen.dart';
import 'package:fclub/feature/club/presentation/widgets/month_payment_details/club_month_payment_filter_bar.dart';
import 'package:fclub/feature/club/presentation/widgets/month_payment_details/club_month_payment_filter_sheet.dart';
import 'package:fclub/feature/club/presentation/widgets/month_payment_details/club_month_payment_hero.dart';
import 'package:fclub/feature/club/presentation/widgets/month_payment_details/club_month_payment_list.dart';
import 'package:fclub/feature/club/presentation/widgets/shared/club_payment_review_actions.dart';
import 'package:fclub/feature/club/presentation/widgets/shared/club_state_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClubMonthPaymentDetailsView extends StatelessWidget {
  const ClubMonthPaymentDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final clubProvider = context.watch<ClubProvider>();
    final detailsProvider = context.watch<ClubMonthPaymentDetailsProvider>();
    final accessiblePayments = clubProvider.visiblePayments;
    final allPayments = detailsProvider.monthPayments(accessiblePayments);
    final visiblePayments = detailsProvider.filteredPayments(
      accessiblePayments,
    );
    final summary = detailsProvider.summary(
      payments: accessiblePayments,
      memberCount: clubProvider.members.length,
      perMemberTarget: clubProvider.monthlyTargetPerMember,
    );
    final paymentUserIds = detailsProvider.paymentUserIds(accessiblePayments);
    final filterMembers = clubProvider.members
        .where((member) => paymentUserIds.contains(member.id))
        .toList(growable: false);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text('club_month_payments_title'.tr())),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: clubProvider.reload,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: ClubMonthPaymentHero(
                  summary: summary,
                  paymentCount: allPayments.length,
                ),
              ),
              SliverToBoxAdapter(
                child: ClubMonthPaymentFilterBar(
                  filter: detailsProvider.filter,
                  shownCount: visiblePayments.length,
                  totalCount: allPayments.length,
                  onStatusChanged: detailsProvider.selectStatus,
                  onClear: detailsProvider.clearFilters,
                  onMoreFilters: () =>
                      _showFilters(context, detailsProvider, filterMembers),
                ),
              ),
              if (clubProvider.isLoading && clubProvider.payments.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (clubProvider.loadError != null && allPayments.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ClubStatePanel(
                    icon: Icons.cloud_off_rounded,
                    title: 'club_payment_load_error'.tr(),
                    message: clubProvider.loadError!,
                    actionLabel: 'group_retry'.tr(),
                    onAction: () => clubProvider.initialize(force: true),
                  ),
                )
              else if (visiblePayments.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ClubStatePanel(
                    icon: detailsProvider.filter.isEmpty
                        ? Icons.calendar_view_month_rounded
                        : Icons.filter_alt_off_rounded,
                    title: detailsProvider.filter.isEmpty
                        ? 'club_no_records_month'.tr()
                        : 'club_payment_no_filter_results'.tr(),
                    message: detailsProvider.filter.isEmpty
                        ? 'club_no_month_payments_message'.tr()
                        : 'club_payment_no_filter_results_message'.tr(),
                    actionLabel: detailsProvider.filter.isEmpty
                        ? null
                        : 'club_clear_filters'.tr(),
                    onAction: detailsProvider.filter.isEmpty
                        ? null
                        : detailsProvider.clearFilters,
                  ),
                )
              else
                ClubMonthPaymentList(
                  payments: visiblePayments,
                  isAdmin: clubProvider.isAdmin,
                  memberById: clubProvider.memberById,
                  onPaymentTap: (payment) =>
                      _openMemberPayments(context, clubProvider, payment),
                  onStatusChanged: (payment, status) =>
                      ClubPaymentReviewActions.updateStatus(
                        context,
                        payment,
                        status,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showFilters(
    BuildContext context,
    ClubMonthPaymentDetailsProvider provider,
    List<ClubMember> members,
  ) async {
    final selected = await showModalBottomSheet<ClubMonthPaymentFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ClubMonthPaymentFilterSheet(
        initialFilter: provider.filter,
        members: members,
      ),
    );
    if (selected == null || !context.mounted) return;
    provider.applyFilter(selected);
  }

  void _openMemberPayments(
    BuildContext context,
    ClubProvider provider,
    ClubPayment payment,
  ) {
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
  }
}
