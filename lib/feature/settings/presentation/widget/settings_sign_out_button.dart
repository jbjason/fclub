import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Full-width destructive account action with an explicit loading state.
class SettingsSignOutButton extends StatelessWidget {
  const SettingsSignOutButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.errorContainer.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: colorScheme.error.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 19.r,
                  height: 19.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    color: colorScheme.error,
                  ),
                )
              else
                Icon(
                  Icons.logout_rounded,
                  color: colorScheme.error,
                  size: 20.r,
                ),
              SizedBox(width: 10.w),
              Text(
                isLoading ? 'signing_out'.tr() : 'sign_out'.tr(),
                style: TextStyle(
                  color: colorScheme.error,
                  fontFamily: MyString.poppinsBold,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
