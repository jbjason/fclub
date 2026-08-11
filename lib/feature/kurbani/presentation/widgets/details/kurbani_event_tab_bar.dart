import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:flutter/material.dart';

class KurbaniEventTabBar extends StatelessWidget {
  const KurbaniEventTabBar({super.key, required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .65),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
      ),
      child: TabBar(
        controller: controller,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [KurbaniPalette.emerald, KurbaniPalette.cyan],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: colors.onSurfaceVariant,
        labelStyle: const TextStyle(
          fontFamily: MyString.rubikMedium,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
        tabs: [
          Tab(text: 'kurbani_tab_expenses'.tr()),
          Tab(text: 'kurbani_tab_settlement'.tr()),
          Tab(text: 'kurbani_tab_parts'.tr()),
        ],
      ),
    );
  }
}
