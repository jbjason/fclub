import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';

import '../../data/model/pack_session.dart';
import 'shared/pack_card_shell.dart';
import 'shared/pack_palette.dart';

class PackHistoryTile extends StatelessWidget {
  const PackHistoryTile({
    super.key,
    required this.session,
    this.onView,
    this.onDelete,
  });

  final PackSession session;
  final VoidCallback? onView;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final date = DateFormat('d MMM y  •  h:mm a').format(session.createdAt);

    return PackCardShell(
      accent: PackPalette.emerald,
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
      onTap: onView,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: PackPalette.emerald.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: PackPalette.emerald,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: MyString.poppinsBold,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontFamily: MyString.rubikRegular,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: PackPalette.violet.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'pack_n_packed'.tr(
                      namedArgs: {'count': '${session.packedCount}'},
                    ),
                    style: const TextStyle(
                      color: PackPalette.violet,
                      fontFamily: MyString.rubikMedium,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'delete'.tr(),
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            color: PackPalette.rose,
          ),
          const Icon(Icons.chevron_right_rounded, color: PackPalette.cyan),
        ],
      ),
    );
  }
}
