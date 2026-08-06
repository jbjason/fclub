import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/home/data/models/user_group.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/user_group_tile.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/user_groups_empty_state.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/user_groups_error_state.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/user_groups_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserGroupsSection extends StatelessWidget {
  const UserGroupsSection({
    super.key,
    required this.groups,
    required this.isLoading,
    required this.hasError,
    required this.selectingGroupId,
    required this.onSelect,
    required this.onRetry,
  });

  final List<UserGroup> groups;
  final bool isLoading;
  final bool hasError;
  final String? selectingGroupId;
  final ValueChanged<UserGroup> onSelect;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: MyColor.secondary.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 39.r,
                height: 39.r,
                decoration: BoxDecoration(
                  color: MyColor.secondary.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(13.r),
                ),
                child: Icon(
                  Icons.account_tree_rounded,
                  size: 20.r,
                  color: MyColor.secondary,
                ),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'group_list_title'.tr(),
                      style: TextStyle(
                        fontFamily: MyString.poppinsBold,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'group_list_description'.tr(),
                      style: TextStyle(
                        fontFamily: MyString.rubikRegular,
                        fontSize: 10.5.sp,
                        height: 1.35,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 13.h),
          if (isLoading)
            const UserGroupsLoading()
          else if (hasError)
            UserGroupsErrorState(onRetry: onRetry)
          else if (groups.isEmpty)
            const UserGroupsEmptyState()
          else
            SizedBox(
              height: 76.h.clamp(72.0, 86.0),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: groups.length,
                separatorBuilder: (_, _) => SizedBox(width: 10.w),
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return UserGroupTile(
                    group: group,
                    isEnabled: selectingGroupId == null,
                    isSelecting: selectingGroupId == group.id,
                    onTap: () => onSelect(group),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
