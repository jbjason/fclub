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
    required this.canRemove,
    required this.onRemove,
  });

  final ClubMember member;
  final bool canRemove;
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
      trailing: member.isAdmin
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: MyColor.primary.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'ADMIN',
                style: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  color: MyColor.primary,
                  fontSize: 8.sp,
                ),
              ),
            )
          : IconButton(
              tooltip: 'Remove member',
              onPressed: canRemove ? onRemove : null,
              icon: const Icon(
                Icons.person_remove_alt_1_rounded,
                color: MyColor.error,
              ),
            ),
    );
  }
}
