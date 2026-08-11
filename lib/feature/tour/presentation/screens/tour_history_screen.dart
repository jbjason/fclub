import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/services/auth/firebase_auth_service.dart';
import 'package:fclub/core/widgets/feature_ambient_background.dart';
import 'package:fclub/feature/home/presentation/provider/group_session_provider.dart';
import 'package:fclub/feature/tour/data/models/tour_event.dart';
import 'package:fclub/feature/tour/data/repositories/tour_repository.dart';
import 'package:fclub/feature/tour/presentation/provider/tour_event_provider.dart';
import 'package:fclub/feature/tour/presentation/provider/tour_provider.dart';
import 'package:fclub/feature/tour/presentation/screens/tour_details_screen.dart';
import 'package:fclub/feature/tour/presentation/widgets/shared/tour_palette.dart';
import 'package:fclub/feature/tour/presentation/widgets/shared/tour_state_panel.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_history/tour_active_session_card.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_history/tour_empty_history_state.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_history/tour_history_app_bar.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_history/tour_history_card.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_history/tour_new_tour_sheet.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_history/tour_overview_header.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_history/tour_project_setup_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TourHistoryScreen extends StatefulWidget {
  const TourHistoryScreen({super.key});

  @override
  State<TourHistoryScreen> createState() => _TourHistoryScreenState();
}

class _TourHistoryScreenState extends State<TourHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<TourProvider>().initialize();
    });
  }

  Future<void> _startNewTour(TourProvider provider) async {
    await provider.loadGroupMembers();
    if (!mounted || provider.actionError != null) {
      if (mounted && provider.actionError != null) {
        _showError(provider.actionError!);
      }
      return;
    }
    final event = await showModalBottomSheet<TourEvent>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .64),
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: const TourNewTourSheet(),
      ),
    );
    if (event != null && mounted) _openEvent(event);
  }

  void _openEvent(TourEvent event) {
    final repository = context.read<TourRepository>();
    final groupSession = context.read<GroupSessionProvider>();
    final authService = context.read<FirebaseAuthService>();
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => TourEventProvider(
            repository: repository,
            groupSession: groupSession,
            authService: authService,
            event: event,
          ),
          child: const TourDetailsScreen(),
        ),
      ),
    );
  }

  Future<void> _confirmFinish(TourProvider provider, TourEvent event) async {
    final confirmed = await _confirm(
      title: 'tour_finish_confirm_title'.tr(),
      message: 'tour_finish_confirm_body'.tr(),
      confirmLabel: 'finish'.tr(),
      destructive: false,
    );
    if (confirmed == true && mounted) {
      await _run(() => provider.completeEvent(event.id));
    }
  }

  Future<void> _confirmDelete(TourProvider provider, TourEvent event) async {
    final confirmed = await _confirm(
      title: 'tour_delete_confirm_title'.tr(),
      message: 'tour_delete_confirm_body'.tr(),
      confirmLabel: 'delete'.tr(),
      destructive: true,
    );
    if (confirmed == true && mounted) {
      await _run(() => provider.deleteEvent(event.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TourProvider>();
    return Scaffold(
      appBar: TourHistoryAppBar(
        title: provider.projectName,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: FeatureAmbientBackground(
          accent: TourPalette.ocean,
          secondaryAccent: TourPalette.sunset,
          child: _body(provider),
        ),
      ),
      floatingActionButton:
          provider.project != null &&
              provider.canManage &&
              provider.activeEvent == null &&
              !provider.isLoading
          ? FloatingActionButton.extended(
              onPressed: provider.isSubmitting
                  ? null
                  : () => _startNewTour(provider),
              backgroundColor: TourPalette.sunset,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.flight_takeoff_rounded),
              label: Text(
                'tour_start'.tr(),
                style: const TextStyle(fontFamily: MyString.poppinsBold),
              ),
            )
          : null,
    );
  }

  Widget _body(TourProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.loadError != null) {
      return TourStatePanel(
        icon: Icons.cloud_off_rounded,
        title: 'tour_load_error_title'.tr(),
        message: provider.loadError!.tr(),
        actionLabel: 'group_retry'.tr(),
        onAction: () => provider.initialize(force: true),
      );
    }
    if (provider.project == null) return const TourProjectSetupPanel();

    final active = provider.activeEvent;
    final history = provider.history;
    return RefreshIndicator(
      onRefresh: () => provider.initialize(force: true),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 8.h),
            sliver: SliverToBoxAdapter(
              child: TourOverviewHeader(
                projectName: provider.projectName,
                eventCount: provider.events.length,
                hasActiveEvent: active != null,
              ),
            ),
          ),
          if (active != null)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 14.h),
              sliver: SliverToBoxAdapter(
                child: TourActiveSessionCard(
                  event: active,
                  canManage: provider.canManage,
                  onResume: () => _openEvent(active),
                  onFinish: () => _confirmFinish(provider, active),
                  onDelete: () => _confirmDelete(provider, active),
                ),
              ),
            ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 10.h),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: TourPalette.sunset,
                    size: 18,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'tour_past_adventures'.tr(),
                    style: TextStyle(
                      fontFamily: MyString.poppinsBold,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (history.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: TourEmptyHistoryState(
                showAction: active == null && provider.canManage,
                onNew: () => _startNewTour(provider),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
              sliver: SliverList.builder(
                itemCount: history.length,
                itemBuilder: (_, index) {
                  final event = history[index];
                  return TourHistoryCard(
                    event: event,
                    canManage: provider.canManage,
                    onOpen: () => _openEvent(event),
                    onDelete: () => _confirmDelete(provider, event),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      if (!mounted) return;
      _showError(
        context.read<TourProvider>().actionError ?? 'tour_error_unknown',
      );
    }
  }

  void _showError(String key) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(key.tr())));
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
        color: destructive ? MyColor.error : TourPalette.lagoon,
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
            backgroundColor: destructive ? MyColor.error : TourPalette.lagoon,
          ),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}
