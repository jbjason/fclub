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
      title: 'Fundora Club',
      subtitle: 'Monthly savings & payment tracking',
      icon: Icons.savings_rounded,
      accent: MyColor.primary,           // Violet Blaze
      route: AppRouteName.club,
    ),
    HomeFeatureItem(
      title: 'Locker',
      subtitle: 'Secure personal vault & credentials',
      icon: Icons.lock_outline_rounded,
      accent: MyColor.secondary,         // Electric Cyan
      route: AppRouteName.locker,
    ),
    HomeFeatureItem(
      title: 'Tour Dashboard',
      subtitle: 'Shared trip expenses & settlements',
      icon: Icons.receipt_long_rounded,
      accent: MyColor.tertiary,          // Rose Red
      route: AppRouteName.tourCostManage,
    ),
    HomeFeatureItem(
      title: 'Kurbani',
      subtitle: 'Animal share & cost distribution',
      icon: Icons.diversity_3_rounded,
      accent: MyColor.warning,           // Amber
      route: AppRouteName.kurbani,
    ),
    HomeFeatureItem(
      title: 'Carry Check',
      subtitle: 'Pack lists & travel checklist',
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
