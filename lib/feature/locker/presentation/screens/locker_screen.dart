import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/widgets/feature_ambient_background.dart';
import 'package:fclub/feature/locker/data/models/locker_transaction.dart';
import 'package:fclub/feature/locker/presentation/provider/locker_provider.dart';
import 'package:fclub/feature/locker/presentation/screens/locker_add_transaction_screen.dart';
import 'package:fclub/feature/locker/presentation/widgets/overview/locker_balance_card.dart';
import 'package:fclub/feature/locker/presentation/widgets/overview/locker_transaction_list.dart';
import 'package:fclub/feature/locker/presentation/widgets/participants/locker_participant_management_sheet.dart';
import 'package:fclub/feature/locker/presentation/widgets/project_setup/locker_project_setup_panel.dart';
import 'package:fclub/feature/locker/presentation/widgets/shared/locker_state_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LockerScreen extends StatefulWidget {
  const LockerScreen({super.key});

  @override
  State<LockerScreen> createState() => _LockerScreenState();
}

class _LockerScreenState extends State<LockerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<LockerProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LockerProvider>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: .92),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.projectName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'locker_page_kicker'.tr(),
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
        actions: [
          if (provider.canManageParticipants && provider.project != null)
            IconButton.filledTonal(
              tooltip: 'locker_manage_participants'.tr(),
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Colors.transparent,
                barrierColor: Colors.black.withValues(alpha: .58),
                builder: (_) => const LockerParticipantManagementSheet(),
              ),
              icon: const Icon(Icons.group_add_rounded),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: FeatureAmbientBackground(
          accent: MyColor.secondary,
          secondaryAccent: MyColor.primary,
          child: _body(provider),
        ),
      ),
      floatingActionButton:
          provider.project != null && provider.canAccessProject
          ? FloatingActionButton.extended(
              backgroundColor: MyColor.secondary,
              foregroundColor: MyColor.onSecondary,
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (_) => const LockerAddTransactionScreen(),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text('locker_add_transaction'.tr()),
            )
          : null,
    );
  }

  Widget _body(LockerProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.loadError != null) {
      return LockerStatePanel(
        icon: Icons.cloud_off_rounded,
        title: 'locker_load_error_title'.tr(),
        message: provider.loadError!,
        actionLabel: 'group_retry'.tr(),
        onAction: () => provider.initialize(force: true),
      );
    }
    if (provider.project == null) return const LockerProjectSetupPanel();
    if (!provider.canAccessProject) {
      return LockerStatePanel(
        icon: Icons.lock_outline_rounded,
        title: 'project_access_required'.tr(),
        message: 'locker_access_required_message'.tr(),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: LockerBalanceCard(
            currentCash: provider.currentCash,
            collected: provider.totalContributions,
            spent: provider.totalExpenses,
            participantCount: provider.participants.length,
            pendingCount: provider.transactions
                .where(
                  (transaction) =>
                      transaction.status == LockerTransactionStatus.pending,
                )
                .length,
            isAdmin: provider.isAdmin,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: _ActivityHeader(
            count: provider.transactions.length,
            pendingCount: provider.transactions
                .where(
                  (transaction) =>
                      transaction.status == LockerTransactionStatus.pending,
                )
                .length,
          ),
        ),
        Expanded(
          child: LockerTransactionList(
            transactions: provider.transactions,
            participants: provider.participants,
          ),
        ),
      ],
    );
  }
}

class _ActivityHeader extends StatelessWidget {
  const _ActivityHeader({required this.count, required this.pendingCount});

  final int count;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 3,
          height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [MyColor.secondary, MyColor.primary],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          'locker_recent_activity'.tr(),
          style: TextStyle(
            color: colors.onSurface,
            fontFamily: MyString.poppinsBold,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        if (pendingCount > 0)
          Container(
            margin: const EdgeInsets.only(right: 7),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: MyColor.warning.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'locker_pending_count'.tr(
                namedArgs: {'count': pendingCount.toString()},
              ),
              style: const TextStyle(
                color: MyColor.warning,
                fontFamily: MyString.rubikMedium,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        Text(
          'locker_total_count'.tr(namedArgs: {'count': count.toString()}),
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontFamily: MyString.rubikRegular,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
