import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/widgets/feature_ambient_background.dart';
import 'package:fclub/feature/kurbani/presentation/provider/kurbani_event_provider.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/details/animal_parts/kurbani_add_animal_part_sheet.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/details/animal_parts/kurbani_animal_parts_tab.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/details/expenses/kurbani_add_expense_sheet.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/details/expenses/kurbani_expense_tab.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/details/kurbani_event_hero.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/details/kurbani_event_tab_bar.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/details/participants/kurbani_participant_management_sheet.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/details/settlement/kurbani_settlement_tab.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_state_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class KurbaniDetailsScreen extends StatefulWidget {
  const KurbaniDetailsScreen({super.key});

  @override
  State<KurbaniDetailsScreen> createState() =>
      _KurbaniDetailsScreenState();
}

class _KurbaniDetailsScreenState extends State<KurbaniDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 3,
    vsync: this,
  )..addListener(_onTabChanged);
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<KurbaniEventProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging && _tabIndex != _tabController.index) {
      setState(() => _tabIndex = _tabController.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KurbaniEventProvider>();
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
              provider.event.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'kurbani_event_kicker'.tr(),
              style: const TextStyle(
                color: KurbaniPalette.gold,
                fontFamily: MyString.rubikMedium,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          if (provider.canEdit)
            IconButton.filledTonal(
              tooltip: 'kurbani_manage_participants'.tr(),
              onPressed: _openParticipants,
              icon: const Icon(Icons.group_add_rounded),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: FeatureAmbientBackground(
          accent: KurbaniPalette.emerald,
          secondaryAccent: KurbaniPalette.violet,
          child: _body(provider),
        ),
      ),
      floatingActionButton: provider.canEdit && _tabIndex != 1
          ? FloatingActionButton.extended(
              backgroundColor: _tabIndex == 0
                  ? KurbaniPalette.cyan
                  : KurbaniPalette.gold,
              foregroundColor: _tabIndex == 0
                  ? Colors.white
                  : KurbaniPalette.midnight,
              onPressed: provider.isSubmitting
                  ? null
                  : _tabIndex == 0
                  ? _openExpense
                  : _openAnimalPart,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                _tabIndex == 0 ? 'add_expense'.tr() : 'kurbani_add_part'.tr(),
              ),
            )
          : null,
    );
  }

  Widget _body(KurbaniEventProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.loadError != null) {
      return KurbaniStatePanel(
        icon: Icons.cloud_off_rounded,
        title: 'kurbani_load_error_title'.tr(),
        message: provider.loadError!.tr(),
        actionLabel: 'group_retry'.tr(),
        onAction: provider.initialize,
      );
    }
    if (!provider.canAccess) {
      return KurbaniStatePanel(
        icon: Icons.lock_outline_rounded,
        title: 'project_access_required'.tr(),
        message: 'kurbani_access_required_message'.tr(),
      );
    }
    return Column(
      children: [
        KurbaniEventHero(
          event: provider.event,
          summary: provider.summary,
          participantCount: provider.participants.length,
        ),
        KurbaniEventTabBar(controller: _tabController),
        const SizedBox(height: 4),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              KurbaniExpenseTab(provider: provider, onDelete: _deleteExpense),
              KurbaniSettlementTab(provider: provider),
              KurbaniAnimalPartsTab(
                provider: provider,
                onDelete: _deleteAnimalPart,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openParticipants() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .6),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<KurbaniEventProvider>(),
        child: const KurbaniParticipantManagementSheet(),
      ),
    );
  }

  void _openExpense() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .6),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<KurbaniEventProvider>(),
        child: const KurbaniAddExpenseSheet(),
      ),
    );
  }

  void _openAnimalPart() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .6),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<KurbaniEventProvider>(),
        child: const KurbaniAddAnimalPartSheet(),
      ),
    );
  }

  void _deleteExpense(String expenseId) {
    _runAction(
      () => context.read<KurbaniEventProvider>().deleteExpense(expenseId),
    );
  }

  void _deleteAnimalPart(String partId) {
    _runAction(
      () => context.read<KurbaniEventProvider>().deleteAnimalPart(partId),
    );
  }

  Future<void> _runAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      if (!mounted) return;
      final key = context.read<KurbaniEventProvider>().actionError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text((key ?? 'kurbani_error_unknown').tr())),
      );
    }
  }
}
