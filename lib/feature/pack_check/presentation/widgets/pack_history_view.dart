import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/model/pack_session.dart';
import '../provider/pack_check_provider.dart';
import 'pack_history_tile.dart';
import 'shared/pack_card_shell.dart';
import 'shared/pack_palette.dart';
import 'shared/pack_section_header.dart';

class PackHistoryView extends StatelessWidget {
  const PackHistoryView({
    super.key,
    this.onCreateNew,
    this.onView,
    this.onDelete,
  });

  final VoidCallback? onCreateNew;
  final void Function(PackSession)? onView;
  final void Function(String id)? onDelete;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PackCheckProvider>();
    final history = provider.history;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CreateSessionButton(onTap: onCreateNew),
        const SizedBox(height: 20),
        PackSectionHeader(
          title: 'pack_past_sessions'.tr(),
          trailingLabel: history.isEmpty ? null : 'pack_clear_history'.tr(),
          onTrailingTap: history.isEmpty
              ? null
              : () => _confirmClearHistory(context, provider),
        ),
        const SizedBox(height: 8),
        if (history.isEmpty)
          const Expanded(child: _EmptyHistory())
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 3, bottom: 28),
              itemCount: history.length,
              itemBuilder: (_, index) => PackHistoryTile(
                session: history[index],
                onView: onView == null ? null : () => onView!(history[index]),
                onDelete: onDelete == null
                    ? null
                    : () => onDelete!(history[index].id),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _confirmClearHistory(
    BuildContext context,
    PackCheckProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.history_toggle_off_rounded,
          color: PackPalette.rose,
        ),
        title: Text(
          'pack_clear_history_title'.tr(),
          style: const TextStyle(fontFamily: MyString.poppinsBold),
        ),
        content: Text(
          'pack_clear_history_body'.tr(),
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
            child: Text('pack_clear'.tr()),
          ),
        ],
      ),
    );
    if (confirmed == true) await provider.clearHistory();
  }
}

class _CreateSessionButton extends StatelessWidget {
  const _CreateSessionButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: onTap == null ? .48 : 1,
    child: Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: PackPalette.actionGradient,
        borderRadius: BorderRadius.circular(19),
        boxShadow: onTap == null
            ? null
            : [
                BoxShadow(
                  color: PackPalette.violet.withValues(alpha: .25),
                  blurRadius: 22,
                  offset: const Offset(0, 9),
                ),
              ],
      ),
      child: FilledButton.icon(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
        ),
        icon: Icon(
          onTap == null ? Icons.lock_outline_rounded : Icons.add_rounded,
        ),
        label: Text(
          onTap == null
              ? 'pack_finish_active_first'.tr()
              : 'pack_start_session'.tr(),
          style: const TextStyle(
            fontFamily: MyString.poppinsBold,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: PackCardShell(
        accent: PackPalette.cyan,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                gradient: PackPalette.actionGradient,
                borderRadius: BorderRadius.circular(21),
              ),
              child: const Icon(
                Icons.travel_explore_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'pack_no_past_sessions'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: MyString.poppinsBold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'pack_no_past_sessions_subtitle'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontFamily: MyString.rubikRegular,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
