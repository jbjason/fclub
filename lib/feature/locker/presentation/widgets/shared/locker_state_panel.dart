import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LockerStatePanel extends StatelessWidget {
  const LockerStatePanel({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68.r,
              height: 68.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    MyColor.secondary.withValues(alpha: .2),
                    MyColor.primary.withValues(alpha: .08),
                  ],
                ),
                border: Border.all(
                  color: MyColor.secondary.withValues(alpha: .16),
                ),
              ),
              child: Icon(icon, size: 30.r, color: MyColor.secondary),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface,
                fontFamily: MyString.poppinsBold,
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 7.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontFamily: MyString.rubikRegular,
                fontSize: 11.5.sp,
                height: 1.45,
              ),
            ),
            if (onAction != null && actionLabel != null) ...[
              SizedBox(height: 18.h),
              FilledButton.tonalIcon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
