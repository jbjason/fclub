import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/locker/data/models/locker_participant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LockerParticipantTile extends StatelessWidget {
  const LockerParticipantTile({
    super.key,
    required this.participant,
    required this.isAdmin,
    required this.canManage,
    required this.canTransferAdmin,
    required this.onRemove,
    required this.onTransferAdmin,
  });

  final LockerParticipant participant;
  final bool isAdmin;
  final bool canManage;
  final bool canTransferAdmin;
  final VoidCallback onRemove;
  final VoidCallback onTransferAdmin;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(
          color: isAdmin
              ? MyColor.secondary.withValues(alpha: .34)
              : colors.outlineVariant.withValues(alpha: .42),
        ),
        gradient: LinearGradient(
          colors: [
            (isAdmin ? MyColor.secondary : MyColor.primary).withValues(
              alpha: .055,
            ),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.fromLTRB(10.w, 4.h, 5.w, 4.h),
        leading: LockerParticipantAvatar(participant: participant),
        title: Text(
          participant.username,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.onSurface,
            fontFamily: MyString.poppinsMedium,
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          participant.email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontFamily: MyString.rubikRegular,
            fontSize: 9.sp,
          ),
        ),
        trailing: isAdmin
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: MyColor.secondary.withValues(alpha: .11),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: MyColor.secondary.withValues(alpha: .18),
                  ),
                ),
                child: Text(
                  'locker_admin_badge'.tr(),
                  style: TextStyle(
                    color: MyColor.secondary,
                    fontFamily: MyString.poppinsBold,
                    fontSize: 7.5.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .4,
                  ),
                ),
              )
            : PopupMenuButton<_ParticipantAction>(
                enabled: canManage,
                tooltip: 'locker_participant_actions'.tr(),
                icon: const Icon(Icons.more_horiz_rounded),
                onSelected: (action) {
                  switch (action) {
                    case _ParticipantAction.transfer:
                      onTransferAdmin();
                    case _ParticipantAction.remove:
                      onRemove();
                  }
                },
                itemBuilder: (context) => [
                  if (canTransferAdmin)
                    PopupMenuItem(
                      value: _ParticipantAction.transfer,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.admin_panel_settings_rounded,
                            color: MyColor.secondary,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text('locker_make_project_admin'.tr()),
                          ),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: _ParticipantAction.remove,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_remove_alt_1_rounded,
                          color: MyColor.error,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'locker_remove_participant'.tr(),
                            style: const TextStyle(color: MyColor.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class LockerParticipantAvatar extends StatelessWidget {
  const LockerParticipantAvatar({
    super.key,
    required this.participant,
    this.size = 42,
  });

  final LockerParticipant participant;
  final double size;

  static const _gradients = <List<Color>>[
    [MyColor.secondary, Color(0xFF2563EB)],
    [MyColor.primary, Color(0xFF7C3AED)],
    [MyColor.tertiary, Color(0xFFDB2777)],
    [MyColor.success, Color(0xFF047857)],
    [MyColor.warning, Color(0xFFEA580C)],
  ];

  @override
  Widget build(BuildContext context) {
    final gradient =
        _gradients[participant.id.hashCode.abs() % _gradients.length];
    final initial = participant.username.trim().isEmpty
        ? '?'
        : participant.username.trim().characters.first.toUpperCase();

    return Container(
      width: size.r,
      height: size.r,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          width: 2,
        ),
      ),
      child: participant.profilePic.isNotEmpty
          ? Image.network(
              participant.profilePic,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _AvatarInitial(initial: initial),
            )
          : _AvatarInitial(initial: initial),
    );
  }
}

class _AvatarInitial extends StatelessWidget {
  const _AvatarInitial({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontFamily: MyString.poppinsBold,
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

enum _ParticipantAction { transfer, remove }
