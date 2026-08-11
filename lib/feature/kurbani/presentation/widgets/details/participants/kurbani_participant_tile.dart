import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_participant.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_avatar.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_card_shell.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:flutter/material.dart';

class KurbaniParticipantTile extends StatelessWidget {
  const KurbaniParticipantTile({
    super.key,
    required this.participant,
    required this.enabled,
    required this.onEdit,
    required this.onRemove,
  });

  final KurbaniParticipant participant;
  final bool enabled;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final paid = participant.paidStatus == KurbaniPaidStatus.paid;
    final accent = paid ? KurbaniPalette.emerald : KurbaniPalette.gold;
    return KurbaniCardShell(
      accent: accent,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          KurbaniAvatar(
            id: participant.id,
            name: participant.username,
            photoUrl: participant.profilePic,
            size: 43,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: MyString.poppinsBold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  CurrencyFormatter.format(participant.contribution),
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontFamily: MyString.rubikRegular,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              (paid ? 'kurbani_paid' : 'kurbani_pending').tr(),
              style: TextStyle(
                color: accent,
                fontFamily: MyString.rubikMedium,
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          PopupMenuButton<String>(
            enabled: enabled,
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'remove') onRemove();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Text('kurbani_edit_contribution'.tr()),
              ),
              PopupMenuItem(
                value: 'remove',
                child: Text('kurbani_remove_participant'.tr()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
