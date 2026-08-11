import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/feature/kurbani/presentation/provider/kurbani_event_provider.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/details/animal_parts/kurbani_animal_part_tile.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/details/animal_parts/kurbani_animal_weight_card.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/details/kurbani_empty_state.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_section_header.dart';
import 'package:flutter/material.dart';

class KurbaniAnimalPartsTab extends StatelessWidget {
  const KurbaniAnimalPartsTab({
    super.key,
    required this.provider,
    required this.onDelete,
  });

  final KurbaniEventProvider provider;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    final parts = provider.animalParts;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      children: [
        KurbaniAnimalWeightCard(
          totalWeight: provider.totalAnimalWeight,
          partCount: parts.length,
          assignedCount: parts
              .where((part) => part.assignedToUid != null)
              .length,
        ),
        const SizedBox(height: 20),
        KurbaniSectionHeader(
          title: 'kurbani_animal_parts'.tr(),
          subtitle: 'kurbani_animal_parts_hint'.tr(),
          icon: Icons.set_meal_rounded,
          accent: KurbaniPalette.gold,
        ),
        const SizedBox(height: 12),
        if (parts.isEmpty)
          KurbaniEmptyState(
            icon: Icons.set_meal_outlined,
            title: 'kurbani_no_parts_title'.tr(),
            message: provider.canEdit
                ? 'kurbani_no_parts_admin'.tr()
                : 'kurbani_no_parts_member'.tr(),
          )
        else
          ...parts.map(
            (part) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: KurbaniAnimalPartTile(
                part: part,
                participants: provider.participants,
                totalWeight: provider.totalAnimalWeight,
                onDelete: provider.canEdit ? () => onDelete(part.id) : null,
              ),
            ),
          ),
      ],
    );
  }
}
