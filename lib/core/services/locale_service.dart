import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;

  Future<void> changeLocale(BuildContext context, String languageCode) async {
    _locale = Locale(languageCode);

    // THIS IS THE KEY LINE - set locale in easy_localization
    await context.setLocale(_locale);

    // Notify listeners AFTER changing locale
    notifyListeners();
  }

  Future<void> toggleLanguage(BuildContext context) async {
    String newLanguage = _locale.languageCode == 'en' ? 'bn' : 'en';
    await changeLocale(context, newLanguage);
  }
}
