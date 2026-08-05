import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/feature/club/data/model/club_member_payment_filter.dart';
import 'package:fclub/feature/club/presentation/provider/club_payment_details_provider.dart';
import 'package:fclub/feature/club/presentation/provider/club_provider.dart';
import 'package:fclub/feature/club/presentation/widgets/payment_details/club_member_payment_hero.dart';
import 'package:fclub/feature/club/presentation/widgets/payment_details/club_payment_detail_tile.dart';
import 'package:fclub/feature/club/presentation/widgets/payment_details/club_payment_details_filter_bar.dart';
import 'package:fclub/feature/club/presentation/widgets/payment_details/club_payment_details_filter_sheet.dart';
import 'package:fclub/feature/club/presentation/widgets/shared/club_state_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ClubPaymentDetailsView extends StatelessWidget {
  const ClubPaymentDetailsView({
    super.key,
    required this.userId,
    this.fallbackName,
    this.fallbackEmail,
  });

  final String userId;
  final String? fallbackName;
  final String? fallbackEmail;

  @override
  Widget build(BuildContext context) {
    final clubProvider = context.watch<ClubProvider>();
    final detailsProvider = context.watch<ClubPaymentDetailsProvider>();
    final member = clubProvider.memberById(userId);
    final allPayments = detailsProvider.memberPayments(clubProvider.payments);
    final visiblePayments = detailsProvider.filteredPayments(
      clubProvider.payments,
    );
    final summary = detailsProvider.summary(clubProvider.payments);
    final displayName = member?.name.trim().isNotEmpty == true
        ? member!.name.trim()
        : fallbackName?.trim().isNotEmpty == true
        ? fallbackName!.trim()
        : 'club_former_member'.tr();
    final email = member?.email.trim().isNotEmpty == true
        ? member!.email.trim()
        : fallbackEmail?.trim() ?? '';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text('club_member_payments_title'.tr())),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => clubProvider.initialize(force: true),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: ClubMemberPaymentHero(
                  userId: userId,
                  name: displayName,
                  email: email,
                  summary: summary,
                ),
              ),
              SliverToBoxAdapter(
                child: ClubPaymentDetailsFilterBar(
                  filter: detailsProvider.filter,
                  shownCount: visiblePayments.length,
                  totalCount: allPayments.length,
                  onStatusChanged: detailsProvider.selectStatus,
                  onClear: detailsProvider.clearFilters,
                  onMoreFilters: () => _showFilters(
                    context,
                    detailsProvider,
                    detailsProvider.availableMonths(clubProvider.payments),
                  ),
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
                        ? Icons.receipt_long_rounded
                        : Icons.filter_alt_off_rounded,
                    title: detailsProvider.filter.isEmpty
                        ? 'club_payment_no_member_records'.tr()
                        : 'club_payment_no_filter_results'.tr(),
                    message: detailsProvider.filter.isEmpty
                        ? 'club_payment_no_member_records_message'.tr()
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
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 28.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 11.h),
                        child: ClubPaymentDetailTile(
                          payment: visiblePayments[index],
                        ),
                      );
                    }, childCount: visiblePayments.length),
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
    ClubPaymentDetailsProvider provider,
    List<String> availableMonths,
  ) async {
    final selected = await showModalBottomSheet<ClubMemberPaymentFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ClubPaymentDetailsFilterSheet(
        initialFilter: provider.filter,
        availableMonths: availableMonths,
      ),
    );
    if (selected == null || !context.mounted) return;
    provider.applyFilter(selected);
  }
}
