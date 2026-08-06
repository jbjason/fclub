import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/home/data/models/user_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserGroupTile extends StatelessWidget {
  const UserGroupTile({
    super.key,
    required this.group,
    required this.isEnabled,
    required this.isSelecting,
    required this.onTap,
  });

  final UserGroup group;
  final bool isEnabled;
  final bool isSelecting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = group.isAdmin ? MyColor.tertiary : MyColor.secondary;

    return SizedBox(
      width: 238.w.clamp(218.0, 258.0),
      child: Material(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(19.r),
        child: InkWell(
          key: ValueKey('user-group-${group.id}'),
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(19.r),
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19.r),
              border: Border.all(color: accent.withValues(alpha: 0.22)),
              gradient: LinearGradient(
                colors: [accent.withValues(alpha: 0.10), Colors.transparent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 43.r,
                  height: 43.r,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    group.isAdmin
                        ? Icons.admin_panel_settings_rounded
                        : Icons.groups_2_rounded,
                    color: accent,
                    size: 21.r,
                  ),
                ),
                SizedBox(width: 11.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: MyString.poppinsBold,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        (group.isAdmin
                                ? 'group_role_admin'
                                : 'group_role_member')
                            .tr(),
                        style: TextStyle(
                          fontFamily: MyString.rubikRegular,
                          fontSize: 9.5.sp,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 7.w),
                if (isSelecting)
                  SizedBox(
                    width: 18.r,
                    height: 18.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: accent,
                    ),
                  )
                else
                  Icon(Icons.arrow_forward_rounded, color: accent, size: 19.r),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
