import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/tour/presentation/widgets/shared/tour_palette.dart';
import 'package:flutter/material.dart';

enum TourManageMenuAction { editBudget, settlementSummary }

class TourManageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TourManageAppBar({
    super.key,
    required this.title,
    required this.canEdit,
    required this.onManageParticipants,
    required this.onEditBudget,
    required this.onOpenSummary,
  });

  final String title;
  final bool canEdit;
  final VoidCallback onManageParticipants;
  final VoidCallback onEditBudget;
  final VoidCallback onOpenSummary;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: colors.surface.withValues(alpha: .92),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(
            'tour_cloud_ledger'.tr(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: TourPalette.ocean,
              fontFamily: MyString.rubikMedium,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
      actions: [
        if (canEdit)
          IconButton.filledTonal(
            tooltip: 'manage_members'.tr(),
            onPressed: onManageParticipants,
            icon: const Icon(Icons.group_add_rounded),
          ),
        PopupMenuButton<TourManageMenuAction>(
          tooltip: MaterialLocalizations.of(context).showMenuTooltip,
          onSelected: (action) {
            switch (action) {
              case TourManageMenuAction.editBudget:
                onEditBudget();
                break;
              case TourManageMenuAction.settlementSummary:
                onOpenSummary();
                break;
            }
          },
          itemBuilder: (_) => [
            if (canEdit)
              PopupMenuItem(
                value: TourManageMenuAction.editBudget,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.tune_rounded),
                  title: Text('tour_edit_budget'.tr()),
                ),
              ),
            PopupMenuItem(
              value: TourManageMenuAction.settlementSummary,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.receipt_long_rounded),
                title: Text('settlement_summary'.tr()),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
