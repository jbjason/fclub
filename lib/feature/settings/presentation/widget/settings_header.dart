import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Decorative introduction for the settings experience.
class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key, this.groupName = ''});

  final String groupName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MyColor.primary.withValues(alpha: isDark ? 0.24 : 0.12),
            MyColor.secondary.withValues(alpha: isDark ? 0.10 : 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: MyColor.primary.withValues(alpha: isDark ? 0.34 : 0.18),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28.r,
            top: -32.r,
            child: Container(
              width: 112.r,
              height: 112.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MyColor.primary.withValues(alpha: isDark ? 0.11 : 0.07),
              ),
            ),
          ),
          Positioned(
            right: 50.r,
            bottom: -28.r,
            child: Container(
              width: 68.r,
              height: 68.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MyColor.secondary.withValues(
                  alpha: isDark ? 0.10 : 0.06,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            MyColor.primary.withValues(alpha: 0.28),
                            MyColor.primary.withValues(alpha: 0.10),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(13.r),
                        border: Border.all(
                          color: MyColor.primary.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: MyColor.adaptiveViolet(context),
                        size: 20.r,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'settings_eyebrow'.tr().toUpperCase(),
                        style: TextStyle(
                          color: MyColor.adaptiveViolet(context),
                          fontFamily: MyString.poppinsBold,
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  'settings_title'.tr(),
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontFamily: MyString.poppinsBold,
                    fontSize: 25.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.18,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  groupName.trim().isEmpty
                      ? 'settings_description'.tr()
                      : 'settings_group_description'.tr(
                          namedArgs: {'name': groupName.trim()},
                        ),
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontFamily: MyString.rubikRegular,
                    fontSize: 12.5.sp,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
