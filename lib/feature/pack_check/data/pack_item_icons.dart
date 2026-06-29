import 'package:flutter/material.dart';

/// Closed set of icons selectable for a [PackItem]. Persisted items only
/// store an icon's `codePoint` (an int), and reconstructing `IconData` from
/// an arbitrary runtime int defeats icon-font tree-shaking at build time.
/// Every icon usable here must therefore be listed as a literal so the
/// build can statically see — and keep — exactly these glyphs.
abstract class PackItemIcons {
  static const List<IconData> choices = [
    Icons.star_rounded,
    Icons.favorite_rounded,
    Icons.bolt_rounded,
    Icons.local_fire_department_rounded,
    Icons.emoji_objects_rounded,
    Icons.music_note_rounded,
    Icons.sports_soccer_rounded,
    Icons.color_lens_rounded,
    Icons.eco_rounded,
    Icons.pets_rounded,
    Icons.card_giftcard_rounded,
    Icons.devices_other_rounded,
  ];

  static const List<IconData> defaults = [
    Icons.watch,
    Icons.smartphone,
    Icons.key,
    Icons.account_balance_wallet,
    Icons.wb_sunny,
    Icons.loop,
    Icons.headphones,
    Icons.description,
    Icons.style,
    Icons.cable,
    Icons.earbuds,
    Icons.laptop,
    Icons.badge,
    Icons.medical_services,
    Icons.beach_access,
    Icons.book,
    Icons.camera_alt,
    Icons.battery_charging_full,
    Icons.shopping_bag,
    Icons.circle_outlined,
  ];

  static const IconData photoFallback = Icons.image;

  static final Map<int, IconData> _byCodePoint = {
    for (final icon in choices) icon.codePoint: icon,
    for (final icon in defaults) icon.codePoint: icon,
    photoFallback.codePoint: photoFallback,
  };

  static IconData resolve(int codePoint) =>
      _byCodePoint[codePoint] ?? photoFallback;
}
