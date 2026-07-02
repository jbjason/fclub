import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/services/locale_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// Human label for a locale, used on the Language tile's subtitle.
String localeName(Locale locale) {
  switch (locale.languageCode) {
    case 'bn':
      return 'বাংলা';
    default:
      return 'English';
  }
}

/// Bottom sheet for picking app language — applies immediately via
/// [LocaleProvider] and persists through [EasyLocalization].
Future<void> showLanguageSheet(BuildContext context) {
  final localeProvider = context.read<LocaleProvider>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: localeProvider,
      child: const _LanguageSheetContent(),
    ),
  );
}

class _LanguageSheetContent extends StatelessWidget {
  const _LanguageSheetContent();

  static const _options = [
    (Locale('en'), Icons.translate_rounded, 'English', 'English (US)'),
    (Locale('bn'), Icons.translate_rounded, 'বাংলা', 'Bangla'),
  ];

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final selected = localeProvider.locale;
    final colorScheme = Theme.of(context).colorScheme;
    const accent = Color(0xFF16A34A);

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
              'language'.tr(),
              style: TextStyle(
                fontFamily: MyString.poppinsBold,
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12.h),
            ..._options.map((option) {
              final (locale, icon, nativeName, englishName) = option;
              final isSelected = locale.languageCode == selected.languageCode;
              return GestureDetector(
                onTap: () async {
                  await localeProvider.changeLocale(context, locale.languageCode);
                  if (context.mounted) Navigator.pop(context);
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accent.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? accent.withValues(alpha: 0.3)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(icon,
                          color: isSelected ? accent : MyColor.gray400,
                          size: 20.r),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nativeName,
                              style: TextStyle(
                                fontFamily: MyString.poppinsMedium,
                                fontSize: 14.sp,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              englishName,
                              style: TextStyle(
                                fontFamily: MyString.rubikRegular,
                                fontSize: 11.sp,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: isSelected ? accent : MyColor.gray300,
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
