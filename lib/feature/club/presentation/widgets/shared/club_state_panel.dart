import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClubStatePanel extends StatelessWidget {
  const ClubStatePanel({
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
              width: 66.r,
              height: 66.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    MyColor.primary.withValues(alpha: .2),
                    MyColor.secondary.withValues(alpha: .08),
                  ],
                ),
              ),
              child: Icon(icon, color: MyColor.primary, size: 30.r),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: MyString.poppinsBold,
                fontSize: 17.sp,
                color: colors.onSurface,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: MyString.rubikRegular,
                fontSize: 12.sp,
                height: 1.45,
                color: colors.onSurfaceVariant,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
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
