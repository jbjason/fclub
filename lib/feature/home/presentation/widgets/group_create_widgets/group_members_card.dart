import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/home/data/models/group_failure.dart';
import 'package:fclub/feature/home/data/models/group_user.dart';
import 'package:fclub/feature/home/presentation/group_failure_localization.dart';
import 'package:fclub/feature/home/presentation/widgets/group_create_widgets/group_form_section_card.dart';
import 'package:fclub/feature/home/presentation/widgets/group_create_widgets/group_member_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupMembersCard extends StatelessWidget {
  const GroupMembersCard({
    super.key,
    required this.creator,
    required this.users,
    required this.selectedMemberCount,
    required this.isLoading,
    required this.loadFailure,
    required this.isSelected,
    required this.onToggle,
    required this.onSearch,
    required this.onRetry,
  });

  final GroupUser creator;
  final List<GroupUser> users;
  final int selectedMemberCount;
  final bool isLoading;
  final GroupFailure? loadFailure;
  final bool Function(String userId) isSelected;
  final void Function(String userId) onToggle;
  final ValueChanged<String> onSearch;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GroupFormSectionCard(
      icon: Icons.group_add_rounded,
      accent: MyColor.secondary,
      title: 'group_members_title'.tr(),
      description: 'group_members_description'.tr(),
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: MyColor.secondary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          'group_member_count'.tr(
            namedArgs: {'count': selectedMemberCount.toString()},
          ),
          style: TextStyle(
            fontFamily: MyString.rubikMedium,
            fontWeight: FontWeight.w600,
            fontSize: 9.sp,
            color: MyColor.secondary,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GroupMemberTile(user: creator, isSelected: true, isCreator: true),
          SizedBox(height: 12.h),
          TextField(
            key: const Key('group-member-search-field'),
            onChanged: onSearch,
            style: TextStyle(
              fontFamily: MyString.rubikRegular,
              fontSize: 12.sp,
            ),
            decoration: InputDecoration(
              hintText: 'group_members_search_hint'.tr(),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: MyColor.secondary,
                size: 19.r,
              ),
              filled: true,
              fillColor: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.7),
              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(
                  color: MyColor.secondary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          _MemberListState(
            users: users,
            isLoading: isLoading,
            loadFailure: loadFailure,
            isSelected: isSelected,
            onToggle: onToggle,
            onRetry: onRetry,
          ),
        ],
      ),
    );
  }
}

class _MemberListState extends StatelessWidget {
  const _MemberListState({
    required this.users,
    required this.isLoading,
    required this.loadFailure,
    required this.isSelected,
    required this.onToggle,
    required this.onRetry,
  });

  final List<GroupUser> users;
  final bool isLoading;
  final GroupFailure? loadFailure;
  final bool Function(String userId) isSelected;
  final void Function(String userId) onToggle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading) {
      return Container(
        height: 112.h,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: MyColor.secondary,
              strokeWidth: 2.5,
            ),
            SizedBox(height: 10.h),
            Text(
              'group_members_loading'.tr(),
              style: TextStyle(
                fontFamily: MyString.rubikRegular,
                fontSize: 10.5.sp,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (loadFailure != null) {
      return _MessageState(
        icon: Icons.cloud_off_rounded,
        message: loadFailure!.localizationKey.tr(),
        actionLabel: 'group_retry'.tr(),
        onAction: onRetry,
      );
    }

    if (users.isEmpty) {
      return _MessageState(
        icon: Icons.person_search_rounded,
        message: 'group_members_empty'.tr(),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 390.h),
      child: ListView.separated(
        shrinkWrap: true,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: users.length,
        separatorBuilder: (_, _) => SizedBox(height: 8.h),
        itemBuilder: (context, index) {
          final user = users[index];
          return GroupMemberTile(
            user: user,
            isSelected: isSelected(user.id),
            isCreator: false,
            onTap: () => onToggle(user.id),
          );
        },
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 22.h),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: colorScheme.outline, size: 25.r),
          SizedBox(height: 7.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: MyString.rubikRegular,
              fontSize: 10.5.sp,
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          if (onAction != null && actionLabel != null) ...[
            SizedBox(height: 7.h),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
