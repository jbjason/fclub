import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../data/pack_item_icons.dart';
import '../provider/pack_check_provider.dart';
import 'shared/pack_palette.dart';

class PackAddItemDialog extends StatefulWidget {
  const PackAddItemDialog({super.key});

  static Future<void> show(BuildContext context) {
    final provider = context.read<PackCheckProvider>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .58),
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: const PackAddItemDialog(),
      ),
    );
  }

  @override
  State<PackAddItemDialog> createState() => _PackAddItemDialogState();
}

class _PackAddItemDialogState extends State<PackAddItemDialog> {
  final _nameController = TextEditingController();
  IconData _selectedIcon = Icons.star_rounded;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit({ImageSource? source}) async {
    final name = _nameController.text.trim();
    if (name.isEmpty && source == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('pack_enter_name_error'.tr())));
      return;
    }
    final provider = context.read<PackCheckProvider>();
    Navigator.pop(context);
    if (source == null) {
      await provider.addCustomItem(name: name, icon: _selectedIcon);
    } else {
      await provider.addPhotoItem(
        name: name.isEmpty ? 'pack_custom_fallback'.tr() : name,
        source: source,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                            Icons.add_photo_alternate_rounded,
                            color: PackPalette.cyan,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Text(
                            'pack_add_custom_item'.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: MyString.poppinsBold,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(fontFamily: MyString.rubikMedium),
                      decoration: InputDecoration(
                        hintText: 'pack_item_name_hint'.tr(),
                        prefixIcon: const Icon(Icons.label_outline_rounded),
                        filled: true,
                        fillColor: colors.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: colors.outlineVariant.withValues(alpha: .5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: PackPalette.violet,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 17),
                    Text(
                      'pack_choose_icon'.tr(),
                      style: const TextStyle(
                        fontFamily: MyString.poppinsBold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 54,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: PackItemIcons.choices.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (_, index) {
                          final icon = PackItemIcons.choices[index];
                          final selected = icon == _selectedIcon;
                          return InkWell(
                            onTap: () => setState(() => _selectedIcon = icon),
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 52,
                              decoration: BoxDecoration(
                                gradient: selected
                                    ? PackPalette.actionGradient
                                    : null,
                                color: selected
                                    ? null
                                    : colors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selected
                                      ? Colors.transparent
                                      : colors.outlineVariant.withValues(
                                          alpha: .5,
                                        ),
                                ),
                              ),
                              child: Icon(
                                icon,
                                color: selected
                                    ? Colors.white
                                    : colors.onSurfaceVariant,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionTile(
                            icon: Icons.add_circle_outline_rounded,
                            label: 'pack_add_icon_item'.tr(),
                            color: PackPalette.violet,
                            onTap: _submit,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: _ActionTile(
                            icon: Icons.camera_alt_rounded,
                            label: 'pack_take_photo'.tr(),
                            color: PackPalette.cyan,
                            onTap: () => _submit(source: ImageSource.camera),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: _ActionTile(
                            icon: Icons.photo_library_rounded,
                            label: 'pack_from_gallery'.tr(),
                            color: PackPalette.emerald,
                            onTap: () => _submit(source: ImageSource.gallery),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: color.withValues(alpha: .11),
    borderRadius: BorderRadius.circular(17),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: color.withValues(alpha: .3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 21),
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: MyString.rubikMedium,
                fontSize: 9,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
