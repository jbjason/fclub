import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_participant.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_avatar.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:flutter/material.dart';

class KurbaniCandidateTile extends StatelessWidget {
  const KurbaniCandidateTile({
    super.key,
    required this.participant,
    required this.enabled,
    required this.onAdd,
  });

  final KurbaniParticipant participant;
  final bool enabled;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .52),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: KurbaniPalette.violet.withValues(alpha: .14)),
      ),
      child: Row(
        children: [
          KurbaniAvatar(
            id: participant.id,
            name: participant.username,
            photoUrl: participant.profilePic,
            size: 41,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.username,
                  style: const TextStyle(
                    fontFamily: MyString.poppinsBold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  participant.email,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontFamily: MyString.rubikRegular,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'kurbani_add_participant'.tr(),
            onPressed: enabled ? onAdd : null,
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 19),
          ),
        ],
      ),
    );
  }
}
