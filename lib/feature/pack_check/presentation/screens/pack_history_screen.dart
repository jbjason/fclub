import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/widgets/feature_ambient_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/pack_check_provider.dart';
import '../widgets/history/pack_history_hero.dart';
import '../widgets/history/pack_new_session_sheet.dart';
import '../widgets/history/pack_resume_session_card.dart';
import '../widgets/history/pack_session_detail_sheet.dart';
import '../widgets/pack_history_view.dart';
import '../widgets/shared/pack_palette.dart';
import 'pack_session_screen.dart';

class PackHistoryScreen extends StatelessWidget {
  const PackHistoryScreen({super.key});

  static Future<void> goToSession(
    BuildContext context,
    PackCheckProvider provider,
  ) => Navigator.push<void>(
    context,
    PageRouteBuilder<void>(
      pageBuilder: (_, animation, secondaryAnimation) =>
          ChangeNotifierProvider.value(
            value: provider,
            child: const PackSessionScreen(),
          ),
      transitionsBuilder: (_, animation, secondaryAnimation, child) =>
          FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(.04, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
    ),
  );

  Future<void> _createSession(
    BuildContext context,
    PackCheckProvider provider,
  ) async {
    if (!provider.canCreateNew) return;
    final name = await PackNewSessionSheet.show(context);
    if (name == null || !context.mounted) return;
    provider.startDraft(name);
    await goToSession(context, provider);
  }

  Future<void> _deleteSession(
    BuildContext context,
    PackCheckProvider provider,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.delete_sweep_rounded, color: PackPalette.rose),
        title: Text(
          'pack_delete_session'.tr(),
          style: const TextStyle(fontFamily: MyString.poppinsBold),
        ),
        content: Text(
          'pack_delete_session_warning'.tr(),
          style: const TextStyle(
            fontFamily: MyString.rubikRegular,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: PackPalette.rose),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
    if (confirmed == true) await provider.deleteSession(id);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        'carry_check'.tr(),
        style: const TextStyle(
          fontFamily: MyString.poppinsBold,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 16),
          child: Chip(
            avatar: const Icon(Icons.auto_awesome_rounded, size: 15),
            label: Text(
              'history'.tr(),
              style: const TextStyle(
                fontFamily: MyString.rubikMedium,
                fontSize: 10,
              ),
            ),
            side: BorderSide(color: PackPalette.violet.withValues(alpha: .28)),
            backgroundColor: PackPalette.violet.withValues(alpha: .08),
          ),
        ),
      ],
    ),
    body: FeatureAmbientBackground(
      accent: PackPalette.violet,
      secondaryAccent: PackPalette.cyan,
      child: Consumer<PackCheckProvider>(
        builder: (context, provider, child) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            children: [
              PackHistoryHero(
                activeSession: provider.activeSession,
                completedCount: provider.history.length,
              ),
              if (provider.hasActiveSession) ...[
                const SizedBox(height: 14),
                PackResumeSessionCard(
                  session: provider.activeSession!,
                  isDraft: provider.isDraftMode,
                  onTap: () => goToSession(context, provider),
                ),
              ],
              const SizedBox(height: 18),
              Expanded(
                child: PackHistoryView(
                  onCreateNew: provider.canCreateNew
                      ? () => _createSession(context, provider)
                      : null,
                  onView: (session) =>
                      PackSessionDetailSheet.show(context, session),
                  onDelete: (id) => _deleteSession(context, provider, id),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
