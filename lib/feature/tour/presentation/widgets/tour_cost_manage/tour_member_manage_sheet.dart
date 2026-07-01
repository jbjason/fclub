import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/services/contacts/global_contacts_provider.dart';
import 'package:fclub/feature/tour/presentation/provider/tour_provider.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_card_shell.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TourMemberManageSheet extends StatelessWidget {
  const TourMemberManageSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<TourProvider>();
    final contacts = context.watch<GlobalContactsProvider>().contacts;
    final currentMemberIds = {for (final m in provider.members) m.id};
    final available =
        contacts.where((c) => !currentMemberIds.contains(c.id)).toList();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.78),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(16.w),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [MyColor.primary, MyColor.tertiary],
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Icon(Icons.people_alt_rounded,
                    color: Colors.white, size: 20.r),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manage Members',
                        style: TextStyle(
                          fontFamily: MyString.poppinsBold,
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${provider.members.length} active · '
                        '${available.length} available to add',
                        style: TextStyle(
                          fontFamily: MyString.rubikRegular,
                          fontSize: 11.sp,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 32.h),
              children: [
                _SectionLabel(
                  icon: Icons.check_circle_rounded,
                  title: 'Current Members',
                  color: MyColor.success,
                ),
                ...provider.members.map((m) {
                  final canRemove = provider.members.length > 1;
                  return _MemberTile(
                    name: m.name,
                    avatarColorIndex: m.avatarColorIndex,
                    canRemove: canRemove,
                    onRemove: canRemove
                        ? () => context.read<TourProvider>().deleteMember(m.id)
                        : null,
                  );
                }),
                if (available.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  _SectionLabel(
                    icon: Icons.person_add_rounded,
                    title: 'Add from Contacts',
                    color: MyColor.primary,
                  ),
                  ...available.map(
                    (c) => _ContactTile(
                      name: c.isMe ? 'You (${c.name})' : c.name,
                      avatarColorIndex: c.avatarColorIndex,
                      onAdd: () => context
                          .read<TourProvider>()
                          .addMemberFromContact(c.id),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.icon,
    required this.title,
    required this.color,
  });
  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 8.h, 4.w, 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 14.r, color: color),
          ),
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(
              fontFamily: MyString.poppinsBold,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.name,
    required this.avatarColorIndex,
    required this.canRemove,
    required this.onRemove,
  });
  final String name;
  final int avatarColorIndex;
  final bool canRemove;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TourCardShell(
      accent: MyColor.success,
      margin: EdgeInsets.only(bottom: 8.h),
      borderRadius: BorderRadius.circular(14.r),
      child: Row(
        children: [
          TourMemberAvatar(
            name: name,
            colorIndex: avatarColorIndex,
            radius: 19.r,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontFamily: MyString.poppinsMedium,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          if (canRemove)
            GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: MyColor.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                      color: MyColor.error.withValues(alpha: 0.28)),
                ),
                child: Icon(Icons.remove_rounded,
                    size: 16.r, color: MyColor.error),
              ),
            )
          else
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: MyColor.success.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.lock_outline_rounded,
                  size: 14.r, color: MyColor.success),
            ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.name,
    required this.avatarColorIndex,
    required this.onAdd,
  });
  final String name;
  final int avatarColorIndex;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TourCardShell(
      accent: MyColor.primary,
      margin: EdgeInsets.only(bottom: 8.h),
      borderRadius: BorderRadius.circular(14.r),
      child: Row(
        children: [
          TourMemberAvatar(
            name: name,
            colorIndex: avatarColorIndex,
            radius: 19.r,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontFamily: MyString.poppinsMedium,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                color: MyColor.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                    color: MyColor.primary.withValues(alpha: 0.35)),
              ),
              child:
                  Icon(Icons.add_rounded, size: 16.r, color: MyColor.primary),
            ),
          ),
        ],
      ),
    );
  }
}
