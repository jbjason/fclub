import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/services/auth/firebase_auth_service.dart';
import 'package:fclub/core/widgets/feature_ambient_background.dart';
import 'package:fclub/feature/home/presentation/provider/group_session_provider.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_event.dart';
import 'package:fclub/feature/kurbani/data/repositories/kurbani_repository.dart';
import 'package:fclub/feature/kurbani/presentation/provider/kurbani_event_provider.dart';
import 'package:fclub/feature/kurbani/presentation/provider/kurbani_provider.dart';
import 'package:fclub/feature/kurbani/presentation/screens/kurbani_details_screen.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/overview/kurbani_event_card.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/overview/kurbani_event_setup_sheet.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/overview/kurbani_overview_hero.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/overview/kurbani_project_setup_panel.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_section_header.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_state_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class KurbaniScreen extends StatefulWidget {
  const KurbaniScreen({super.key});

  @override
  State<KurbaniScreen> createState() => _KurbaniScreenState();
}

class _KurbaniScreenState extends State<KurbaniScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<KurbaniProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KurbaniProvider>();
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
              provider.project?.name ?? 'kurbani_feature_title'.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'kurbani_page_kicker'.tr(),
              style: const TextStyle(
                color: KurbaniPalette.emerald,
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
          accent: KurbaniPalette.emerald,
          secondaryAccent: KurbaniPalette.violet,
          child: _body(provider),
        ),
      ),
      floatingActionButton:
          provider.project != null &&
              provider.canManage &&
              provider.activeEvent == null
          ? FloatingActionButton.extended(
              backgroundColor: KurbaniPalette.emerald,
              foregroundColor: Colors.white,
              onPressed: provider.isSubmitting ? null : _openEventSetup,
              icon: const Icon(Icons.add_rounded),
              label: Text('kurbani_new_event'.tr()),
            )
          : null,
    );
  }

  Widget _body(KurbaniProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.loadError != null) {
      return KurbaniStatePanel(
        icon: Icons.cloud_off_rounded,
        title: 'kurbani_load_error_title'.tr(),
        message: provider.loadError!.tr(),
        actionLabel: 'group_retry'.tr(),
        onAction: () => provider.initialize(force: true),
      );
    }
    if (provider.project == null) return const KurbaniProjectSetupPanel();

    final active = provider.activeEvent;
    final completed = provider.completedEvents;
    return RefreshIndicator(
      onRefresh: () => provider.initialize(force: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
        children: [
          KurbaniOverviewHero(
            projectName: provider.projectName,
            activeEvent: active,
            completedCount: completed.length,
          ),
          const SizedBox(height: 24),
          KurbaniSectionHeader(
            title: 'kurbani_current_event'.tr(),
            subtitle: active == null
                ? 'kurbani_no_current_event'.tr()
                : 'kurbani_current_event_hint'.tr(),
            icon: Icons.auto_awesome_rounded,
            accent: KurbaniPalette.emerald,
          ),
          const SizedBox(height: 11),
          if (active == null)
            KurbaniStatePanel(
              icon: Icons.nightlight_outlined,
              title: 'kurbani_ready_for_event'.tr(),
              message: provider.canManage
                  ? 'kurbani_ready_admin_message'.tr()
                  : 'kurbani_ready_member_message'.tr(),
            )
          else
            KurbaniEventCard(
              event: active,
              canManage: provider.canManage,
              onOpen: () => _openManagement(active),
              onComplete: () => _confirmComplete(active),
              onDelete: () => _confirmDelete(active),
            ),
          const SizedBox(height: 25),
          KurbaniSectionHeader(
            title: 'kurbani_event_history'.tr(),
            subtitle: 'kurbani_history_count'.tr(
              namedArgs: {'count': '${completed.length}'},
            ),
            icon: Icons.history_rounded,
            accent: KurbaniPalette.violet,
          ),
          const SizedBox(height: 11),
          if (completed.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Text(
                'kurbani_no_history'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontFamily: MyString.rubikRegular,
                  fontSize: 12,
                ),
              ),
            )
          else
            ...completed.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: KurbaniEventCard(
                  event: event,
                  canManage: provider.canManage,
                  onOpen: () => _openManagement(event),
                  onDelete: () => _confirmDelete(event),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openEventSetup() async {
    final event = await showModalBottomSheet<KurbaniEvent>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .6),
      builder: (_) => const KurbaniEventSetupSheet(),
    );
    if (event != null && mounted) _openManagement(event);
  }

  void _openManagement(KurbaniEvent event) {
    final repository = context.read<KurbaniRepository>();
    final groupSession = context.read<GroupSessionProvider>();
    final authService = context.read<FirebaseAuthService>();
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => KurbaniEventProvider(
            repository: repository,
            groupSession: groupSession,
            authService: authService,
            event: event,
          ),
          child: const KurbaniDetailsScreen(),
        ),
      ),
    );
  }

  Future<void> _confirmComplete(KurbaniEvent event) async {
    final confirmed = await _confirm(
      title: 'kurbani_finish_title'.tr(),
      message: 'kurbani_finish_body'.tr(),
      confirmLabel: 'kurbani_finish'.tr(),
      destructive: false,
    );
    if (confirmed != true || !mounted) return;
    await _run(() => context.read<KurbaniProvider>().completeEvent(event.id));
  }

  Future<void> _confirmDelete(KurbaniEvent event) async {
    final confirmed = await _confirm(
      title: 'kurbani_delete_title'.tr(namedArgs: {'name': event.name}),
      message: 'kurbani_delete_body'.tr(),
      confirmLabel: 'delete'.tr(),
      destructive: true,
    );
    if (confirmed != true || !mounted) return;
    await _run(() => context.read<KurbaniProvider>().deleteEvent(event.id));
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
    required bool destructive,
  }) => showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: Icon(
        destructive ? Icons.delete_outline_rounded : Icons.task_alt_rounded,
        color: destructive ? KurbaniPalette.rose : KurbaniPalette.emerald,
      ),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text('cancel'.tr()),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: destructive
                ? KurbaniPalette.rose
                : KurbaniPalette.emerald,
          ),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      if (!mounted) return;
      final key = context.read<KurbaniProvider>().actionError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text((key ?? 'kurbani_error_unknown').tr())),
      );
    }
  }
}
