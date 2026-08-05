import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/club/data/model/club_member.dart';
import 'package:fclub/feature/club/presentation/widgets/club_member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClubMemberCandidateTile extends StatelessWidget {
  const ClubMemberCandidateTile({
    super.key,
    required this.member,
    required this.onAdd,
  });

  final ClubMemberCandidate member;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
      leading: ClubMemberAvatar(
        name: member.name,
        colorIndex: member.id.hashCode.abs(),
        radius: 19.r,
      ),
      title: Text(
        member.name,
        style: TextStyle(fontFamily: MyString.poppinsMedium, fontSize: 12.sp),
      ),
      subtitle: Text(
        member.email,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontFamily: MyString.rubikRegular, fontSize: 9.sp),
      ),
      trailing: FilledButton.tonalIcon(
        onPressed: onAdd,
        icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
        label: const Text('Add'),
        style: FilledButton.styleFrom(foregroundColor: MyColor.primary),
      ),
    );
  }
}
