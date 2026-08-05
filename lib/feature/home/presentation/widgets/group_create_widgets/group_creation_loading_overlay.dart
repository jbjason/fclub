import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupCreationLoadingOverlay extends StatelessWidget {
  const GroupCreationLoadingOverlay({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.38),
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 42.w),
          padding: EdgeInsets.all(22.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: MyColor.primary.withValues(alpha: 0.24)),
            boxShadow: [
              BoxShadow(
                color: MyColor.primary.withValues(alpha: 0.18),
                blurRadius: 30,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24.r,
                height: 24.r,
                child: const CircularProgressIndicator(
                  color: MyColor.primary,
                  strokeWidth: 2.8,
                ),
              ),
              SizedBox(width: 14.w),
              Flexible(
                child: Text(
                  'group_creation_syncing'.tr(),
                  style: TextStyle(
                    fontFamily: MyString.poppinsMedium,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
