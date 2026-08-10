import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';

import '../shared/pack_card_shell.dart';
import '../shared/pack_palette.dart';

class PackInstructionCard extends StatelessWidget {
  const PackInstructionCard({super.key, required this.isCheckMode});

  final bool isCheckMode;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = isCheckMode ? PackPalette.cyan : PackPalette.violet;
    return PackCardShell(
      accent: accent,
      padding: const EdgeInsets.all(13),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isCheckMode ? Icons.fact_check_outlined : Icons.touch_app_rounded,
              color: accent,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCheckMode
                      ? 'pack_check_heading'.tr()
                      : 'pack_pack_heading'.tr(),
                  style: const TextStyle(
                    fontFamily: MyString.poppinsBold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isCheckMode
                      ? 'pack_verify_description'.tr()
                      : 'pack_select_description'.tr(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontFamily: MyString.rubikRegular,
                    fontSize: 10,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
