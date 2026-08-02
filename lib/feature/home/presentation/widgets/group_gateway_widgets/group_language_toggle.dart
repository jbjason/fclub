import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/services/locale_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class GroupLanguageToggle extends StatelessWidget {
  const GroupLanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final isBangla = context.watch<LocaleProvider>().languageCode == 'bn';
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: 'change_language'.tr(),
      child: Material(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(24.r),
        child: InkWell(
          onTap: () => context.read<LocaleProvider>().toggleLanguage(context),
          borderRadius: BorderRadius.circular(24.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.70),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.translate_rounded,
                  color: MyColor.primary,
                  size: 16.r,
                ),
                SizedBox(width: 6.w),
                Text(
                  isBangla ? 'EN' : 'বাং',
                  style: TextStyle(
                    fontFamily: MyString.poppinsMedium,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
