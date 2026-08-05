import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/home/data/models/group_user.dart';
import 'package:fclub/feature/home/presentation/widgets/group_create_widgets/group_member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupMemberTile extends StatelessWidget {
  const GroupMemberTile({
    super.key,
    required this.user,
    required this.isSelected,
    required this.isCreator,
    this.onTap,
  });

  final GroupUser user;
  final bool isSelected;
  final bool isCreator;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = isCreator ? MyColor.tertiary : MyColor.primary;

    return Semantics(
      button: !isCreator,
      selected: isSelected,
      child: Material(
        color: isSelected
            ? accent.withValues(alpha: 0.08)
            : colorScheme.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(15.r),
        child: InkWell(
          key: ValueKey<String>('group-member-${user.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(15.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 10.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.r),
              border: Border.all(
                color: isSelected
                    ? accent.withValues(alpha: 0.28)
                    : colorScheme.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              children: [
                GroupMemberAvatar(user: user),
                SizedBox(width: 11.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.username,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: MyString.poppinsMedium,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5.sp,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (isCreator) ...[
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: MyColor.tertiary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                'group_admin_badge'.tr(),
                                style: TextStyle(
                                  fontFamily: MyString.rubikMedium,
                                  fontSize: 7.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: MyColor.tertiary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (user.email.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          user.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: MyString.rubikRegular,
                            fontSize: 9.5.sp,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                if (isCreator)
                  Container(
                    width: 30.r,
                    height: 30.r,
                    decoration: BoxDecoration(
                      color: MyColor.tertiary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      color: MyColor.tertiary,
                      size: 16.r,
                    ),
                  )
                else
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 30.r,
                    height: 30.r,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? MyColor.primary
                          : colorScheme.surfaceContainerLowest,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? MyColor.primary
                            : colorScheme.outlineVariant,
                      ),
                    ),
                    child: Icon(
                      isSelected ? Icons.check_rounded : Icons.add_rounded,
                      color: isSelected ? Colors.white : colorScheme.outline,
                      size: 17.r,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
