import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/club/data/model/club_member.dart';
import 'package:fclub/feature/club/presentation/widgets/club_member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClubMemberTile extends StatelessWidget {
  const ClubMemberTile({
    super.key,
    required this.member,
    required this.isAdmin,
    required this.canManage,
    this.canTransferAdmin = true,
    required this.onTransferAdmin,
    required this.onRemove,
  });

  final ClubMember member;
  final bool isAdmin;
  final bool canManage;
  final bool canTransferAdmin;
  final VoidCallback onTransferAdmin;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
      leading: ClubMemberAvatar(
        name: member.name,
        colorIndex: member.id.hashCode.abs(),
        radius: 20.r,
      ),
      title: Text(
        member.name,
        style: TextStyle(fontFamily: MyString.poppinsMedium, fontSize: 12.5.sp),
      ),
      subtitle: Text(
        member.email.isEmpty ? member.id : member.email,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: MyString.rubikRegular,
          fontSize: 9.5.sp,
          color: colors.onSurfaceVariant,
        ),
      ),
      trailing: isAdmin
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: MyColor.primary.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'club_admin_badge'.tr(),
                style: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  color: MyColor.primary,
                  fontSize: 8.sp,
                ),
              ),
            )
          : PopupMenuButton<_ClubMemberAction>(
              key: ValueKey('club-member-actions-${member.id}'),
              enabled: canManage,
              tooltip: 'club_member_actions'.tr(),
              onSelected: (action) {
                switch (action) {
                  case _ClubMemberAction.transferAdmin:
                    onTransferAdmin();
                  case _ClubMemberAction.remove:
                    onRemove();
                }
              },
              itemBuilder: (context) => [
                if (canTransferAdmin)
                  PopupMenuItem(
                    value: _ClubMemberAction.transferAdmin,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.admin_panel_settings_rounded,
                          color: MyColor.primary,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(child: Text('club_transfer_admin'.tr())),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: _ClubMemberAction.remove,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_remove_alt_1_rounded,
                        color: MyColor.error,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'club_remove_member'.tr(),
                          style: const TextStyle(color: MyColor.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

enum _ClubMemberAction { transferAdmin, remove }
