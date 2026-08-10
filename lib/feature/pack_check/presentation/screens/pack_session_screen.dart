import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/widgets/feature_ambient_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/pack_check_provider.dart';
import '../widgets/pack_add_item_dialog.dart';
import '../widgets/pack_items_grid.dart';
import '../widgets/session/pack_instruction_card.dart';
import '../widgets/session/pack_session_action_bar.dart';
import '../widgets/session/pack_session_hero.dart';
import '../widgets/session/pack_verify_list.dart';
import '../widgets/shared/pack_palette.dart';

class PackSessionScreen extends StatefulWidget {
  const PackSessionScreen({super.key});

  @override
  State<PackSessionScreen> createState() => _PackSessionScreenState();
}

class _PackSessionScreenState extends State<PackSessionScreen> {
  bool _allowPop = false;

  Future<void> _exitAfterStateUpdate() async {
    setState(() => _allowPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) Navigator.pop(context);
  }

  Future<void> _handleBack(
    BuildContext context,
    PackCheckProvider provider,
  ) async {
    if (provider.isCheckMode) {
      provider.enterPackMode();
      return;
    }
    if (!provider.isDraftMode) {
      Navigator.pop(context);
      return;
    }

    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.edit_off_rounded, color: PackPalette.rose),
        title: Text(
          'pack_discard_title'.tr(),
          style: const TextStyle(fontFamily: MyString.poppinsBold),
        ),
        content: Text(
          'pack_discard_body'.tr(),
          style: const TextStyle(
            fontFamily: MyString.rubikRegular,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('pack_keep_editing'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: PackPalette.rose),
            child: Text('pack_discard'.tr()),
          ),
        ],
      ),
    );
    if (discard == true && context.mounted) {
      provider.discardDraft();
      await _exitAfterStateUpdate();
    }
  }

  Future<void> _complete(
    BuildContext context,
    PackCheckProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.verified_rounded, color: PackPalette.emerald),
        title: Text(
          'pack_all_clear'.tr(),
          style: const TextStyle(fontFamily: MyString.poppinsBold),
        ),
        content: Text(
          'pack_all_clear_body'.tr(),
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
            style: FilledButton.styleFrom(backgroundColor: PackPalette.emerald),
            child: Text('pack_complete'.tr()),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await provider.completeSession();
    if (context.mounted) await _exitAfterStateUpdate();
  }

  @override
  Widget build(BuildContext context) => Consumer<PackCheckProvider>(
    builder: (context, provider, child) {
      final session = provider.activeSession;
      return PopScope(
        canPop: _allowPop || (!provider.isDraftMode && !provider.isCheckMode),
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _handleBack(context, provider);
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => _handleBack(context, provider),
              icon: Icon(
                provider.isCheckMode
                    ? Icons.arrow_back_rounded
                    : provider.isDraftMode
                    ? Icons.close_rounded
                    : Icons.arrow_back_rounded,
              ),
            ),
            title: Text(
              provider.isCheckMode
                  ? 'pack_verify_return'.tr()
                  : 'pack_select_items'.tr(),
              style: const TextStyle(
                fontFamily: MyString.poppinsBold,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          body: FeatureAmbientBackground(
            accent: provider.isCheckMode
                ? PackPalette.cyan
                : PackPalette.violet,
            secondaryAccent: provider.isCheckMode
                ? PackPalette.violet
                : PackPalette.cyan,
            child: session == null
                ? Center(
                    child: Text(
                      'pack_no_active'.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: MyString.rubikRegular),
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: PackSessionHero(
                          session: session,
                          isCheckMode: provider.isCheckMode,
                          isDraft: provider.isDraftMode,
                          onPackTap: provider.enterPackMode,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 13, 16, 7),
                        child: PackInstructionCard(
                          isCheckMode: provider.isCheckMode,
                        ),
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          child: provider.isCheckMode
                              ? PackVerifyList(
                                  key: const ValueKey('verify'),
                                  provider: provider,
                                )
                              : const PackItemsGrid(key: ValueKey('pack')),
                        ),
                      ),
                      if (!provider.isCheckMode && provider.hasPackedItems)
                        PackSessionActionBar(
                          icon: provider.isDraftMode
                              ? Icons.rocket_launch_rounded
                              : Icons.fact_check_rounded,
                          label: provider.isDraftMode
                              ? 'pack_confirm_start'.tr()
                              : 'pack_back_step2'.tr(),
                          subtitle: provider.isDraftMode
                              ? 'pack_items_selected_sublabel'.tr(
                                  namedArgs: {
                                    'count': '${session.packedCount}',
                                  },
                                )
                              : 'pack_items_to_verify_count'.tr(
                                  namedArgs: {
                                    'count': '${session.packedCount}',
                                  },
                                ),
                          onTap: provider.isDraftMode
                              ? provider.confirmDraft
                              : provider.enterCheckMode,
                        ),
                      if (provider.isCheckMode && session.allCheckedBack)
                        PackSessionActionBar(
                          icon: Icons.verified_rounded,
                          label: 'pack_all_here'.tr(),
                          subtitle: 'pack_session_move_to_history'.tr(),
                          completed: true,
                          onTap: () => _complete(context, provider),
                        ),
                    ],
                  ),
          ),
          floatingActionButton: session != null && !provider.isCheckMode
              ? Container(
                  decoration: BoxDecoration(
                    gradient: PackPalette.actionGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: PackPalette.violet.withValues(alpha: .3),
                        blurRadius: 18,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    heroTag: 'pack-add-item',
                    onPressed: () => PackAddItemDialog.show(context),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: const Icon(Icons.add_rounded, color: Colors.white),
                  ),
                )
              : null,
        ),
      );
    },
  );
}
