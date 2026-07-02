import 'package:fclub/config/router/app_router.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/feature/home/presentation/widgets/home_feature_card.dart';
import 'package:fclub/feature/home/presentation/widgets/home_feature_item.dart';
import 'package:flutter/material.dart';

/// Renders the complete catalogue of navigable features as a vertical column
/// of [HomeFeatureCard] widgets.
///
/// The feature catalogue is defined as a compile-time `const` list so no
/// allocation occurs on every build. Adding or reordering features only
/// requires editing [_features].
class HomeFeatureGrid extends StatelessWidget {
  const HomeFeatureGrid({super.key});

  // ── Feature catalogue (compile-time constant) ─────────────────────────────

  static const List<HomeFeatureItem> _features = [
    HomeFeatureItem(
      title: 'club_feature_title',
      subtitle: 'club_feature_subtitle',
      icon: Icons.savings_rounded,
      accent: MyColor.primary,           // Violet Blaze
      route: AppRouteName.club,
    ),
    HomeFeatureItem(
      title: 'locker_feature_title',
      subtitle: 'locker_feature_subtitle',
      icon: Icons.lock_outline_rounded,
      accent: MyColor.secondary,         // Electric Cyan
      route: AppRouteName.locker,
    ),
    HomeFeatureItem(
      title: 'tour_feature_title',
      subtitle: 'tour_feature_subtitle',
      icon: Icons.receipt_long_rounded,
      accent: MyColor.tertiary,          // Rose Red
      route: AppRouteName.tourCostManage,
    ),
    HomeFeatureItem(
      title: 'kurbani_feature_title',
      subtitle: 'kurbani_feature_subtitle',
      icon: Icons.diversity_3_rounded,
      accent: MyColor.warning,           // Amber
      route: AppRouteName.kurbani,
    ),
    HomeFeatureItem(
      title: 'pack_feature_title',
      subtitle: 'pack_feature_subtitle',
      icon: Icons.backpack_rounded,
      accent: MyColor.success,           // Emerald Green
      route: AppRouteName.packCheck,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _features
          .map(
            (item) => HomeFeatureCard(
              item: item,
              onTap: () => Navigator.pushNamed(context, item.route),
            ),
          )
          .toList(),
    );
  }
}
