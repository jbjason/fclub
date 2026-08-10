import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../data/model/pack_item.dart';
import '../provider/pack_check_provider.dart';
import 'pack_item_card.dart';
import 'shared/pack_card_shell.dart';
import 'shared/pack_palette.dart';

class PackItemsGrid extends StatelessWidget {
  const PackItemsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PackCheckProvider>();
    final session = provider.activeSession;
    if (session == null) return const SizedBox.shrink();

    if (session.items.isEmpty) {
      return Center(
        child: PackCardShell(
          accent: PackPalette.violet,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                color: PackPalette.violet,
                size: 42,
              ),
              const SizedBox(height: 10),
              Text(
                'pack_no_items_found'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: MyString.rubikRegular,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 5.h, 16.w, 108.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: .82,
      ),
      itemCount: session.items.length,
      itemBuilder: (_, index) {
        final item = session.items[index];
        return PackItemCard(
          item: item,
          onTap: () => provider.togglePacked(item.id),
          onLongPress: item.isCustom
              ? () => _confirmDelete(context, provider, item)
              : null,
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    PackCheckProvider provider,
    PackItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded, color: PackPalette.rose),
        title: Text(
          'pack_remove_item_title'.tr(namedArgs: {'name': item.name}),
          style: const TextStyle(fontFamily: MyString.poppinsBold),
        ),
        content: Text(
          'pack_remove_item_body'.tr(),
          style: const TextStyle(
            fontFamily: MyString.rubikRegular,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: PackPalette.rose),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
    if (confirmed == true) await provider.removeCustomItem(item.id);
  }
}
