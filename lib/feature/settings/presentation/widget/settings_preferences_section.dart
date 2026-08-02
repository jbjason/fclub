import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/feature/settings/presentation/widget/settings_language_sheet.dart';
import 'package:fclub/feature/settings/presentation/widget/settings_section.dart';
import 'package:fclub/feature/settings/presentation/widget/settings_theme_sheet.dart';
import 'package:fclub/feature/settings/presentation/widget/settings_tile.dart';
import 'package:flutter/material.dart';

/// User-selectable application presentation preferences.
class SettingsPreferencesSection extends StatelessWidget {
  const SettingsPreferencesSection({
    super.key,
    required this.themeMode,
    required this.locale,
  });

  final ThemeMode themeMode;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'preferences'.tr(),
      accent: MyColor.primary,
      children: [
        SettingsTile(
          icon: _themeIcon,
          accent: MyColor.primary,
          title: 'appearance'.tr(),
          subtitle: themeModeLabel(themeMode),
          onTap: () => showThemeModeSheet(context),
        ),
        SettingsTile(
          icon: Icons.language_rounded,
          accent: MyColor.secondary,
          title: 'language'.tr(),
          subtitle: localeName(locale),
          onTap: () => showLanguageSheet(context),
        ),
      ],
    );
  }

  IconData get _themeIcon {
    switch (themeMode) {
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
    }
  }
}
