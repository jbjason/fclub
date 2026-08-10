import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/pack_check/data/model/pack_session.dart';
import 'package:flutter/material.dart';

import '../shared/pack_card_shell.dart';
import '../shared/pack_palette.dart';

class PackResumeSessionCard extends StatelessWidget {
  const PackResumeSessionCard({
    super.key,
    required this.session,
    required this.isDraft,
    required this.onTap,
  });

  final PackSession session;
  final bool isDraft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = isDraft ? PackPalette.amber : PackPalette.violet;

    return PackCardShell(
      accent: accent,
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accent, accent.withValues(alpha: .62)],
              ),
              borderRadius: BorderRadius.circular(17),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: .23),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Icon(
              isDraft ? Icons.edit_note_rounded : Icons.route_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 13),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isDraft
                      ? 'pack_draft_subtitle'.tr(
                          namedArgs: {'count': '${session.packedCount}'},
                        )
                      : 'pack_active_subtitle'.tr(
                          namedArgs: {
                            'packed': '${session.packedCount}',
                            'total': '${session.items.length}',
                          },
                        ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontFamily: MyString.rubikRegular,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .13),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_forward_rounded, color: accent, size: 20),
          ),
        ],
      ),
    );
  }
}
