import 'package:flutter/material.dart';

/// Persisted app-wide preferences.
class AppSettings {
  const AppSettings({required this.themeMode});

  final ThemeMode themeMode;

  factory AppSettings.defaults() => const AppSettings(themeMode: ThemeMode.system);

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    final rawIndex = map['themeMode'] as int?;
    final isValidIndex = rawIndex != null && rawIndex >= 0 && rawIndex < ThemeMode.values.length;
    return AppSettings(
      themeMode: isValidIndex ? ThemeMode.values[rawIndex] : ThemeMode.system,
    );
  }

  Map<String, dynamic> toMap() => {'themeMode': themeMode.index};

  AppSettings copyWith({ThemeMode? themeMode}) {
    return AppSettings(themeMode: themeMode ?? this.themeMode);
  }
}
