import 'package:easy_localization/easy_localization.dart';

extension KurbaniPartDisplayExtension on String {
  String get localizedKurbaniPartName {
    const knownParts = {
      'meat',
      'bone',
      'liver',
      'ribs',
      'offal',
      'head',
      'feet',
    };
    return knownParts.contains(this) ? 'kurbani_part_$this'.tr() : this;
  }
}
