import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/home/data/models/group_failure.dart';
import 'package:fclub/feature/home/presentation/group_failure_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupCreateSubmitBar extends StatelessWidget {
  const GroupCreateSubmitBar({
    super.key,
    required this.memberCount,
    required this.isSubmitting,
    required this.failure,
    required this.onSubmit,
  });

  final int memberCount;
  final bool isSubmitting;
  final GroupFailure? failure;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 11.h, 20.w, 12.h),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: isDark ? 0.96 : 0.94),
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.07),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (failure != null) ...[
            Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: colorScheme.error,
                  size: 15.r,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    failure!.localizationKey.tr(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: MyString.rubikRegular,
                      fontSize: 9.5.sp,
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
          ],
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17.r),
              gradient: LinearGradient(
                colors: isSubmitting
                    ? [colorScheme.outline, colorScheme.outline]
                    : const [MyColor.primary, MyColor.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: isSubmitting
                  ? null
                  : [
                      BoxShadow(
                        color: MyColor.primary.withValues(alpha: 0.27),
                        blurRadius: 18,
                        spreadRadius: -5,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(17.r),
              child: InkWell(
                key: const Key('create-group-submit-button'),
                onTap: isSubmitting ? null : onSubmit,
                borderRadius: BorderRadius.circular(17.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSubmitting)
                        SizedBox(
                          width: 18.r,
                          height: 18.r,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.2,
                          ),
                        )
                      else
                        Icon(
                          Icons.rocket_launch_rounded,
                          color: Colors.white,
                          size: 19.r,
                        ),
                      SizedBox(width: 9.w),
                      Flexible(
                        child: Text(
                          isSubmitting
                              ? 'group_creating'.tr()
                              : 'group_create_with_count'.tr(
                                  namedArgs: {'count': memberCount.toString()},
                                ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: MyString.poppinsBold,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (!isSubmitting) ...[
                        SizedBox(width: 9.w),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white.withValues(alpha: 0.85),
                          size: 17.r,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
