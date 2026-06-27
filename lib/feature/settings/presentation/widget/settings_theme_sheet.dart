import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/settings/presentation/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// Human label for a [ThemeMode], used on the Appearance tile's subtitle.
String themeModeLabel(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.system:
      return 'System default';
    case ThemeMode.light:
      return 'Light';
    case ThemeMode.dark:
      return 'Dark';
  }
}

/// Bottom sheet letting the user pick Light/Dark/System — applies
/// immediately via [SettingsProvider.setThemeMode] and persists.
Future<void> showThemeModeSheet(BuildContext context) {
  final settingsProvider = context.read<SettingsProvider>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: settingsProvider,
      child: const _ThemeModeSheetContent(),
    ),
  );
}

class _ThemeModeSheetContent extends StatelessWidget {
  const _ThemeModeSheetContent();

  static const _options = [
    (ThemeMode.system, Icons.brightness_auto_rounded),
    (ThemeMode.light, Icons.light_mode_rounded),
    (ThemeMode.dark, Icons.dark_mode_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final selected = settingsProvider.settings.themeMode;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: MyColor.outlineVariant,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            Text(
              'Appearance',
              style: TextStyle(
                fontFamily: MyString.poppinsBold,
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12.h),
            ..._options.map((option) {
              final (mode, icon) = option;
              final isSelected = mode == selected;
              return GestureDetector(
                onTap: () async {
                  await settingsProvider.setThemeMode(mode);
                  if (context.mounted) Navigator.pop(context);
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? MyColor.primary.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? MyColor.primary.withValues(alpha: 0.3)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: isSelected ? MyColor.primary : MyColor.gray400, size: 20.r),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          themeModeLabel(mode),
                          style: TextStyle(
                            fontFamily: MyString.poppinsMedium,
                            fontSize: 14.sp,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        color: isSelected ? MyColor.primary : MyColor.gray300,
                        size: 20.r,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
