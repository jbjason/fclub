import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';

import '../../provider/pack_check_provider.dart';
import '../pack_checklist_tile.dart';
import '../shared/pack_card_shell.dart';
import '../shared/pack_palette.dart';

class PackVerifyList extends StatelessWidget {
  const PackVerifyList({super.key, required this.provider});

  final PackCheckProvider provider;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final session = provider.activeSession!;
    final items = session.items.where((item) => item.isPacked).toList()
      ..sort(
        (a, b) => a.isCheckedBack == b.isCheckedBack
            ? 0
            : a.isCheckedBack
            ? 1
            : -1,
      );

    if (items.isEmpty) {
      return Center(
        child: PackCardShell(
          accent: PackPalette.cyan,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                color: PackPalette.cyan,
                size: 42,
              ),
              const SizedBox(height: 10),
              Text(
                'pack_no_packed_to_verify'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontFamily: MyString.rubikRegular,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 104),
      itemCount: items.length,
      itemBuilder: (_, index) => PackChecklistTile(
        item: items[index],
        onToggle: () => provider.toggleCheckedBack(items[index].id),
      ),
    );
  }
}
