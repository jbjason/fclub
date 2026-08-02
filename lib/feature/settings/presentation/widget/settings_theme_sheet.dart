import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/feature/settings/presentation/provider/settings_provider.dart';
import 'package:fclub/feature/settings/presentation/widget/settings_option_tile.dart';
import 'package:fclub/feature/settings/presentation/widget/settings_sheet_shell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

String themeModeLabel(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.system:
      return 'system_default'.tr();
    case ThemeMode.light:
      return 'theme_light'.tr();
    case ThemeMode.dark:
      return 'theme_dark'.tr();
  }
}

String _themeModeDescription(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.system:
      return 'theme_system_subtitle'.tr();
    case ThemeMode.light:
      return 'theme_light_subtitle'.tr();
    case ThemeMode.dark:
      return 'theme_dark_subtitle'.tr();
  }
}

Future<void> showThemeModeSheet(BuildContext context) {
  final settingsProvider = context.read<SettingsProvider>();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: settingsProvider,
      child: const SettingsThemeSheet(),
    ),
  );
}

/// Theme-mode selection content.
class SettingsThemeSheet extends StatelessWidget {
  const SettingsThemeSheet({super.key});

  static const _options = [
    (ThemeMode.system, Icons.brightness_auto_rounded),
    (ThemeMode.light, Icons.light_mode_rounded),
    (ThemeMode.dark, Icons.dark_mode_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final selected = provider.settings.themeMode;

    return SettingsSheetShell(
      icon: Icons.palette_outlined,
      accent: MyColor.adaptiveViolet(context),
      title: 'appearance'.tr(),
      subtitle: 'theme_sheet_description'.tr(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _options.map((option) {
          final (mode, icon) = option;
          return SettingsOptionTile(
            icon: icon,
            accent: MyColor.adaptiveViolet(context),
            title: themeModeLabel(mode),
            subtitle: _themeModeDescription(mode),
            isSelected: selected == mode,
            onTap: () => _selectMode(context, provider, mode),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _selectMode(
    BuildContext context,
    SettingsProvider provider,
    ThemeMode mode,
  ) async {
    await provider.setThemeMode(mode);
    if (context.mounted) Navigator.pop(context);
  }
}
