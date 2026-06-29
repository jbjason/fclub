import 'package:flutter/material.dart';

/// Immutable view-model that describes a single navigable feature entry
/// shown on the home dashboard.
///
/// All fields are compile-time constants so the catalogue in
/// [HomeFeatureGrid] can be declared as a `const List`.
class HomeFeatureItem {
  const HomeFeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.route,
  });

  /// Primary display name shown on the card.
  final String title;

  /// Short descriptive hint rendered below the title.
  final String subtitle;

  /// Material icon that visually represents the feature.
  final IconData icon;

  /// Accent colour used for the icon container gradient and card tint.
  ///
  /// Should be a `const` [Color] (e.g. from [MyColor]) so the list
  /// item itself can remain `const`.
  final Color accent;

  /// Named route pushed when the card is tapped (see [AppRouteName]).
  final String route;
}
