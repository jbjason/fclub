import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupSecretCodeField extends StatelessWidget {
  const GroupSecretCodeField({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.r),
      borderSide: BorderSide(
        color: MyColor.primary.withValues(alpha: isDark ? 0.34 : 0.22),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'group_secret_code_label'.tr(),
          style: TextStyle(
            fontFamily: MyString.poppinsMedium,
            fontWeight: FontWeight.w600,
            fontSize: 11.sp,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 7.h),
        TextField(
          key: const Key('group-secret-code-field'),
          textCapitalization: TextCapitalization.characters,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.done,
          style: TextStyle(
            fontFamily: MyString.rubikMedium,
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
            color: colorScheme.onSurface,
            letterSpacing: 1.2,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(
              alpha: isDark ? 0.48 : 0.58,
            ),
            hintText: 'group_secret_code_hint'.tr(),
            hintStyle: TextStyle(
              fontFamily: MyString.rubikRegular,
              fontSize: 12.sp,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.70),
              letterSpacing: 0.7,
            ),
            prefixIcon: Icon(
              Icons.key_rounded,
              color: MyColor.primary,
              size: 19.r,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 15.w,
              vertical: 15.h,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: const BorderSide(color: MyColor.primary, width: 1.5),
            ),
          ),
        ),
        SizedBox(height: 7.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 13.r,
              color: colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: 5.w),
            Expanded(
              child: Text(
                'group_secret_code_helper'.tr(),
                style: TextStyle(
                  fontFamily: MyString.rubikRegular,
                  fontSize: 9.5.sp,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
