import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';

import '../shared/pack_palette.dart';

class PackNewSessionSheet extends StatefulWidget {
  const PackNewSessionSheet({super.key});

  static Future<String?> show(BuildContext context) =>
      showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: .58),
        builder: (_) => const PackNewSessionSheet(),
      );

  @override
  State<PackNewSessionSheet> createState() => _PackNewSessionSheetState();
}

class _PackNewSessionSheetState extends State<PackNewSessionSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    Navigator.pop(
      context,
      value.isEmpty ? 'pack_default_trip_name'.tr() : value,
    );
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
                padding: const EdgeInsets.fromLTRB(20, 10, 12, 20),
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
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .11),
                            borderRadius: BorderRadius.circular(17),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: .15),
                            ),
                          ),
                          child: const Icon(
                            Icons.explore_rounded,
                            color: PackPalette.cyan,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'pack_where_heading'.tr().toUpperCase(),
                                style: const TextStyle(
                                  color: PackPalette.cyan,
                                  fontFamily: MyString.rubikMedium,
                                  fontSize: 9,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                'pack_new_session'.tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: MyString.poppinsBold,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'pack_where_heading'.tr(),
                      style: const TextStyle(
                        fontFamily: MyString.poppinsBold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _controller,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      style: const TextStyle(fontFamily: MyString.rubikMedium),
                      decoration: InputDecoration(
                        hintText: 'pack_trip_name_hint'.tr(),
                        prefixIcon: const Icon(Icons.location_on_outlined),
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
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: PackPalette.actionGradient,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: PackPalette.violet.withValues(alpha: .24),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: FilledButton.icon(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: Text(
                            'pack_create'.tr(),
                            style: const TextStyle(
                              fontFamily: MyString.poppinsBold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
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
