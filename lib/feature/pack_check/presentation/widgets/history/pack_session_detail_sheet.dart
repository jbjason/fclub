import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/pack_check/data/model/pack_item.dart';
import 'package:fclub/feature/pack_check/data/model/pack_session.dart';
import 'package:fclub/feature/pack_check/data/pack_item_icons.dart';
import 'package:flutter/material.dart';

import '../shared/pack_palette.dart';

class PackSessionDetailSheet extends StatelessWidget {
  const PackSessionDetailSheet({super.key, required this.session});

  final PackSession session;

  static Future<void> show(BuildContext context, PackSession session) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: .58),
        builder: (_) => PackSessionDetailSheet(session: session),
      );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final packed = session.items.where((item) => item.isPacked).toList();
    final date = DateFormat('d MMM y  •  h:mm a').format(session.createdAt);

    return FractionallySizedBox(
      heightFactor: .86,
      child: Material(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 12, 18),
              decoration: const BoxDecoration(
                gradient: PackPalette.heroGradient,
              ),
              child: Column(
                children: [
                  Container(
                    width: 46,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: const Icon(
                          Icons.inventory_2_rounded,
                          color: PackPalette.cyan,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'pack_packed_items'.tr().toUpperCase(),
                              style: const TextStyle(
                                color: PackPalette.cyan,
                                fontFamily: MyString.rubikMedium,
                                fontSize: 9,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              session.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: MyString.poppinsBold,
                                fontSize: 19,
                              ),
                            ),
                            Text(
                              date,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .58),
                                fontFamily: MyString.rubikRegular,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: packed.isEmpty
                  ? Center(
                      child: Text(
                        'pack_no_items_packed'.tr(),
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontFamily: MyString.rubikRegular,
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(18),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: .9,
                          ),
                      itemCount: packed.length,
                      itemBuilder: (_, index) =>
                          _DetailItem(item: packed[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({required this.item});

  final PackItem item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .7),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: PackPalette.violet.withValues(alpha: .22)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (item.imagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.file(
                File(item.imagePath!),
                width: 42,
                height: 42,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image_outlined,
                  color: PackPalette.violet,
                  size: 32,
                ),
              ),
            )
          else
            Icon(
              PackItemIcons.resolve(item.iconCodePoint),
              color: PackPalette.violet,
              size: 34,
            ),
          const SizedBox(height: 8),
          Text(
            item.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: MyString.rubikMedium,
              fontSize: 10,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
