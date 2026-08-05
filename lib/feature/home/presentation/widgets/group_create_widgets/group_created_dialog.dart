import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/home/data/models/created_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupCreatedDialog extends StatelessWidget {
  const GroupCreatedDialog({
    super.key,
    required this.group,
    required this.onContinue,
  });

  final CreatedGroup group;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 440,
        padding: EdgeInsets.all(22.w),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(color: MyColor.success.withValues(alpha: 0.28)),
          boxShadow: [
            BoxShadow(
              color: MyColor.success.withValues(alpha: 0.18),
              blurRadius: 34,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [MyColor.success, MyColor.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: MyColor.success.withValues(alpha: 0.26),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.done_all_rounded,
                color: Colors.white,
                size: 34.r,
              ),
            ),
            SizedBox(height: 17.h),
            Text(
              'group_created_title'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: MyString.poppinsBold,
                fontWeight: FontWeight.w700,
                fontSize: 20.sp,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              'group_created_description'.tr(namedArgs: {'name': group.name}),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: MyString.rubikRegular,
                fontSize: 11.5.sp,
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            SizedBox(height: 17.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 13.h),
              decoration: BoxDecoration(
                color: MyColor.primary.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: MyColor.primary.withValues(alpha: 0.22),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'group_created_pin_label'.tr(),
                          style: TextStyle(
                            fontFamily: MyString.rubikMedium,
                            fontSize: 8.sp,
                            color: MyColor.primary,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          group.pinCode,
                          style: TextStyle(
                            fontFamily: MyString.poppinsBold,
                            fontWeight: FontWeight.w700,
                            fontSize: 18.sp,
                            color: colorScheme.onSurface,
                            letterSpacing: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'copy'.tr(),
                    onPressed: () => _copyPin(context),
                    icon: Icon(Icons.copy_rounded, size: 18.r),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'group_created_members'.tr(
                namedArgs: {'count': group.memberCount.toString()},
              ),
              style: TextStyle(
                fontFamily: MyString.rubikRegular,
                fontSize: 10.sp,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 18.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onContinue,
                style: FilledButton.styleFrom(
                  backgroundColor: MyColor.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                ),
                icon: Icon(Icons.home_rounded, size: 18.r),
                label: Text(
                  'group_created_continue'.tr(),
                  style: TextStyle(
                    fontFamily: MyString.poppinsBold,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyPin(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: group.pinCode));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('group_pin_copied'.tr())));
  }
}
