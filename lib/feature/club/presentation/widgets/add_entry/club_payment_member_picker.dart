import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/club/data/model/club_member.dart';
import 'package:fclub/feature/club/presentation/widgets/club_card_shell.dart';
import 'package:fclub/feature/club/presentation/widgets/club_member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClubPaymentMemberPicker extends StatelessWidget {
  const ClubPaymentMemberPicker({
    super.key,
    required this.members,
    required this.currentMember,
    required this.isAdmin,
    required this.selectedMemberId,
    required this.onSelected,
    required this.onManageMembers,
  });

  final List<ClubMember> members;
  final ClubMember? currentMember;
  final bool isAdmin;
  final String? selectedMemberId;
  final ValueChanged<String> onSelected;
  final VoidCallback onManageMembers;

  @override
  Widget build(BuildContext context) {
    if (!isAdmin) return _buildCurrentMember(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'PAYMENT FOR',
              style: TextStyle(
                fontFamily: MyString.poppinsBold,
                fontSize: 9.sp,
                letterSpacing: 1.1,
                color: MyColor.primary,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onManageMembers,
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 17),
              label: const Text('Add member'),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          '${members.length} group members · admin entries are saved as paid',
          style: TextStyle(
            fontFamily: MyString.rubikRegular,
            fontSize: 9.5.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 10.h),
        if (members.isEmpty)
          ClubCardShell(
            accent: MyColor.warning,
            child: const Text('No group members are available yet.'),
          )
        else
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: members
                .map((member) {
                  final selected = member.id == selectedMemberId;
                  return ChoiceChip(
                    selected: selected,
                    onSelected: (_) => onSelected(member.id),
                    avatar: ClubMemberAvatar(
                      name: member.name,
                      colorIndex: member.id.hashCode.abs(),
                      radius: 11.r,
                    ),
                    label: Text(member.name),
                    side: BorderSide(
                      color: selected
                          ? MyColor.primary
                          : MyColor.primary.withValues(alpha: .18),
                    ),
                    selectedColor: MyColor.primary.withValues(alpha: .15),
                  );
                })
                .toList(growable: false),
          ),
      ],
    );
  }

  Widget _buildCurrentMember(BuildContext context) {
    final member = currentMember;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MEMBER',
          style: TextStyle(
            fontFamily: MyString.poppinsBold,
            fontSize: 9.sp,
            letterSpacing: 1.1,
            color: MyColor.primary,
          ),
        ),
        SizedBox(height: 8.h),
        ClubCardShell(
          accent: MyColor.primary,
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              ClubMemberAvatar(
                name: member?.name ?? 'Member',
                colorIndex: member?.id.hashCode.abs() ?? 0,
                radius: 18.r,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member?.name ?? 'Signed-in member',
                      style: TextStyle(
                        fontFamily: MyString.poppinsMedium,
                        fontSize: 12.sp,
                      ),
                    ),
                    Text(
                      'Your payment will be submitted as pending.',
                      style: TextStyle(
                        fontFamily: MyString.rubikRegular,
                        fontSize: 9.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.lock_rounded, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}
