import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_participant.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_avatar.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:flutter/material.dart';

class KurbaniEventMemberTile extends StatelessWidget {
  const KurbaniEventMemberTile({
    super.key,
    required this.member,
    required this.selected,
    required this.onChanged,
  });

  final KurbaniParticipant member;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? KurbaniPalette.emerald.withValues(alpha: .1)
            : colors.surface.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          borderRadius: BorderRadius.circular(17),
          onTap: () => onChanged(!selected),
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Row(
              children: [
                KurbaniAvatar(
                  id: member.id,
                  name: member.username,
                  photoUrl: member.profilePic,
                  size: 42,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.username,
                        style: const TextStyle(
                          fontFamily: MyString.poppinsBold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        member.email,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontFamily: MyString.rubikRegular,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: selected,
                  onChanged: (v) => onChanged(v ?? false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
