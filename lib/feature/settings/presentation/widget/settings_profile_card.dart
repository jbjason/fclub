import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Signed-in account summary displayed as the screen's primary card.
class SettingsProfileCard extends StatelessWidget {
  const SettingsProfileCard({
    super.key,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.emailVerified,
    required this.onTap,
  });

  final String displayName;
  final String email;
  final String photoUrl;
  final bool emailVerified;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = MyColor.adaptiveViolet(context);

    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(22.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.r),
        child: Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MyColor.primary.withValues(alpha: isDark ? 0.16 : 0.07),
                MyColor.secondary.withValues(alpha: isDark ? 0.07 : 0.025),
                Colors.transparent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.62),
            ),
          ),
          child: Row(
            children: [
              _buildAvatar(accent),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontFamily: MyString.poppinsBold,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontFamily: MyString.rubikRegular,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _buildVerificationBadge(context, isDark),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withValues(alpha: 0.22)),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: accent,
                  size: 16.r,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Color accent) {
    final initials = _initials(displayName);

    return Container(
      width: 62.r,
      height: 62.r,
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [MyColor.primary, MyColor.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: MyColor.primary.withValues(alpha: 0.20),
            blurRadius: 14.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17.r),
        child: photoUrl.isEmpty
            ? _buildInitialsAvatar(initials, accent)
            : Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    _buildInitialsAvatar(initials, accent),
              ),
      ),
    );
  }

  Widget _buildInitialsAvatar(String initials, Color accent) {
    return Container(
      color: MyColor.darkSurfaceContainerHigh,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: accent,
          fontFamily: MyString.poppinsBold,
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildVerificationBadge(BuildContext context, bool isDark) {
    final statusColor = emailVerified ? MyColor.success : MyColor.warning;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: isDark ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: statusColor.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            emailVerified ? Icons.verified_rounded : Icons.info_outline_rounded,
            color: statusColor,
            size: 13.r,
          ),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              emailVerified ? 'verified_account'.tr() : 'unverified_email'.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontFamily: MyString.poppinsMedium,
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String value) {
    final words = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2);
    final result = words.map((word) => word.characters.first).join();
    return result.isEmpty ? 'F' : result.toUpperCase();
  }
}
