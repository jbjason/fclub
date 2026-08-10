import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_event.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:flutter/material.dart';

class KurbaniStatusBadge extends StatelessWidget {
  const KurbaniStatusBadge({super.key, required this.status});

  final KurbaniEventStatus status;

  @override
  Widget build(BuildContext context) {
    final active = status == KurbaniEventStatus.active;
    final color = active ? KurbaniPalette.emerald : KurbaniPalette.violet;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: .25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            (active ? 'kurbani_status_active' : 'kurbani_status_completed')
                .tr(),
            style: TextStyle(
              color: color,
              fontFamily: MyString.rubikMedium,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
