import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_event.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_card_shell.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_status_badge.dart';
import 'package:flutter/material.dart';

class KurbaniEventCard extends StatelessWidget {
  const KurbaniEventCard({
    super.key,
    required this.event,
    required this.onOpen,
    required this.canManage,
    this.onComplete,
    this.onDelete,
  });

  final KurbaniEvent event;
  final VoidCallback onOpen;
  final bool canManage;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = event.isActive
        ? KurbaniPalette.emerald
        : KurbaniPalette.violet;
    final locale = context.locale.toString();
    return KurbaniCardShell(
      accent: accent,
      onTap: onOpen,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accent, KurbaniPalette.cyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              event.isActive
                  ? Icons.auto_awesome_rounded
                  : Icons.history_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: MyString.poppinsBold,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    KurbaniStatusBadge(status: event.status),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'kurbani_event_created'.tr(
                    namedArgs: {
                      'date': DateFormat.yMMMd(locale).format(event.createdAt),
                    },
                  ),
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontFamily: MyString.rubikRegular,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (canManage)
            PopupMenuButton<String>(
              tooltip: 'kurbani_event_actions'.tr(),
              onSelected: (value) {
                if (value == 'complete') onComplete?.call();
                if (value == 'delete') onDelete?.call();
              },
              itemBuilder: (_) => [
                if (event.isActive)
                  PopupMenuItem(
                    value: 'complete',
                    child: Text('kurbani_finish'.tr()),
                  ),
                PopupMenuItem(value: 'delete', child: Text('delete'.tr())),
              ],
            )
          else
            Icon(Icons.chevron_right_rounded, color: colors.outline),
        ],
      ),
    );
  }
}
