import 'package:flutter/material.dart';

import 'model/pack_item.dart';

/// Provides the default item catalog seeded into every new [PackSession].
abstract class DefaultPackItems {
  static List<PackItem> get catalog => [
        _item('default_watch', 'Watch', Icons.watch),
        _item('default_mobile', 'Mobile', Icons.smartphone),
        _item('default_key', 'Key', Icons.key),
        _item('default_wallet', 'Wallet', Icons.account_balance_wallet),
        _item('default_sunglasses', 'Sunglasses', Icons.wb_sunny),
        _item('default_bracelet', 'Bracelet', Icons.loop),
        _item('default_headphones', 'Headphones', Icons.headphones),
        _item('default_documents', 'Documents', Icons.description),
        _item('default_hat', 'Hat', Icons.style),
        _item('default_charger', 'Charger', Icons.cable),
        _item('default_earbuds', 'Earbuds', Icons.earbuds),
        _item('default_laptop', 'Laptop', Icons.laptop),
        _item('default_passport', 'Passport', Icons.badge),
        _item('default_medicine', 'Medicine', Icons.medical_services),
        _item('default_umbrella', 'Umbrella', Icons.beach_access),
        _item('default_notebook', 'Notebook', Icons.book),
        _item('default_camera', 'Camera', Icons.camera_alt),
        _item('default_powerbank', 'Power Bank', Icons.battery_charging_full),
        _item('default_bag', 'Bag', Icons.shopping_bag),
        _item('default_ring', 'Ring', Icons.circle_outlined),
      ];

  static PackItem _item(String id, String name, IconData icon) => PackItem(
        id: id,
        name: name,
        iconCodePoint: icon.codePoint,
      );
}
