import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_animal_part.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_participant.dart';
import 'package:fclub/feature/kurbani/presentation/extensions/kurbani_part_display_extension.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_card_shell.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:flutter/material.dart';

class KurbaniAnimalPartTile extends StatelessWidget {
  const KurbaniAnimalPartTile({
    super.key,
    required this.part,
    required this.participants,
    required this.totalWeight,
    this.onDelete,
  });

  final KurbaniAnimalPart part;
  final List<KurbaniParticipant> participants;
  final double totalWeight;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final assignedName = _assignedName();
    final percent = totalWeight <= 0 ? 0 : part.weightKg / totalWeight * 100;
    return KurbaniCardShell(
      accent: KurbaniPalette.gold,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [KurbaniPalette.gold, KurbaniPalette.rose],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.set_meal_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  part.name.localizedKurbaniPartName,
                  style: const TextStyle(
                    fontFamily: MyString.poppinsBold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  assignedName == null
                      ? 'kurbani_unassigned'.tr()
                      : 'kurbani_assigned_to'.tr(
                          namedArgs: {'name': assignedName},
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontFamily: MyString.rubikRegular,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'kurbani_weight_value'.tr(
                  namedArgs: {'weight': part.weightKg.toStringAsFixed(1)},
                ),
                style: const TextStyle(
                  color: KurbaniPalette.gold,
                  fontFamily: MyString.poppinsBold,
                  fontSize: 13,
                ),
              ),
              Text(
                'kurbani_weight_percent'.tr(
                  namedArgs: {'percent': percent.toStringAsFixed(0)},
                ),
                style: TextStyle(
                  color: colors.outline,
                  fontFamily: MyString.rubikRegular,
                  fontSize: 8.5,
                ),
              ),
            ],
          ),
          if (onDelete != null)
            IconButton(
              tooltip: 'delete'.tr(),
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: KurbaniPalette.rose,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  String? _assignedName() {
    final id = part.assignedToUid;
    if (id == null) return null;
    for (final participant in participants) {
      if (participant.id == id) return participant.username;
    }
    return null;
  }
}
