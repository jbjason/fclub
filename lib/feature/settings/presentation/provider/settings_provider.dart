import 'package:fclub/feature/settings/data/model/app_settings.dart';
import 'package:fclub/feature/settings/data/repository/settings_repository.dart';
import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  SettingsProvider(this._settingsRepository)
      : _settings = _settingsRepository.loadSettings();

  final SettingsRepository _settingsRepository;
  AppSettings _settings;

  AppSettings get settings => _settings;

  Future<void> setThemeMode(ThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    notifyListeners();
    await _settingsRepository.saveSettings(_settings);
  }

  Future<void> updateEmployeeProfile({
    required BuildContext context,
    required String uid,
    required String name,
    required String phone,
    required String photoUrl,
  }) async {
    try {
      await _settingsRepository.updateEmployee(
        context,
        uid: uid,
        name: name,
        phone: phone,
        photoUrl: photoUrl,
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
