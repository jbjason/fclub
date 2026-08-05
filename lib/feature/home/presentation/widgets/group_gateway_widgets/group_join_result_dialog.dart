import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupJoinResultDialog extends StatelessWidget {
  const GroupJoinResultDialog({
    super.key,
    required this.icon,
    required this.accent,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
    this.groupName,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;
  final String? groupName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 25.w),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 430,
        padding: EdgeInsets.all(22.w),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(color: accent.withValues(alpha: 0.28)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.19),
              blurRadius: 36,
              spreadRadius: -5,
              offset: const Offset(0, 15),
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
                gradient: LinearGradient(
                  colors: [accent, accent.withValues(alpha: 0.66)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: colorScheme.surfaceContainerLowest,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.28),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 33.r),
            ),
            SizedBox(height: 17.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: MyString.poppinsBold,
                fontWeight: FontWeight.w700,
                fontSize: 20.sp,
                color: colorScheme.onSurface,
              ),
            ),
            if (groupName != null && groupName!.isNotEmpty) ...[
              SizedBox(height: 9.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: accent.withValues(alpha: 0.20)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.groups_2_rounded, color: accent, size: 15.r),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        groupName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: MyString.poppinsMedium,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.sp,
                          color: accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 9.h),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: MyString.rubikRegular,
                fontSize: 11.5.sp,
                color: colorScheme.onSurfaceVariant,
                height: 1.48,
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('group-join-dialog-action'),
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                ),
                icon: Icon(Icons.arrow_forward_rounded, size: 18.r),
                label: Text(
                  actionLabel,
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
}
