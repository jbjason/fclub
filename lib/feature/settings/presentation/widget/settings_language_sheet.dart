import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/services/locale_service.dart';
import 'package:fclub/feature/settings/presentation/widget/settings_option_tile.dart';
import 'package:fclub/feature/settings/presentation/widget/settings_sheet_shell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

String localeName(Locale locale) {
  return locale.languageCode == 'bn'
      ? 'language_bangla'.tr()
      : 'language_english'.tr();
}

Future<void> showLanguageSheet(BuildContext context) {
  final localeProvider = context.read<LocaleProvider>();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: localeProvider,
      child: const SettingsLanguageSheet(),
    ),
  );
}

/// App-language selection content.
class SettingsLanguageSheet extends StatelessWidget {
  const SettingsLanguageSheet({super.key});

  static const _options = [
    (Locale('en'), Icons.translate_rounded),
    (Locale('bn'), Icons.g_translate_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final selected = localeProvider.locale;

    return SettingsSheetShell(
      icon: Icons.language_rounded,
      accent: MyColor.secondary,
      title: 'language'.tr(),
      subtitle: 'language_sheet_description'.tr(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _options.map((option) {
          final (locale, icon) = option;
          return SettingsOptionTile(
            icon: icon,
            accent: MyColor.secondary,
            title: localeName(locale),
            subtitle: locale.languageCode == 'bn'
                ? 'language_bangla_region'.tr()
                : 'language_english_region'.tr(),
            isSelected: selected.languageCode == locale.languageCode,
            onTap: () => _selectLocale(context, localeProvider, locale),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _selectLocale(
    BuildContext context,
    LocaleProvider provider,
    Locale locale,
  ) async {
    await provider.changeLocale(context, locale.languageCode);
    if (context.mounted) Navigator.pop(context);
  }
}
