import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/tour/data/models/tour_participant.dart';
import 'package:fclub/feature/tour/presentation/widgets/shared/tour_palette.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourNewTourStepTwo extends StatelessWidget {
  const TourNewTourStepTwo({
    super.key,
    required this.members,
    required this.currentUserId,
    required this.selectedIds,
    required this.isSubmitting,
    required this.onToggle,
    required this.onSubmit,
  });

  final List<TourParticipantCandidate> members;
  final String? currentUserId;
  final Set<String> selectedIds;
  final bool isSubmitting;
  final void Function(String id) onToggle;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selectedCount = {
      ...selectedIds,
      if (currentUserId != null) currentUserId,
    }.length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 350.h),
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: members.length,
            itemBuilder: (_, index) {
              final member = members[index];
              final isMe = member.id == currentUserId;
              final isSelected = isMe || selectedIds.contains(member.id);
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Material(
                  color: isSelected
                      ? TourPalette.ocean.withValues(alpha: .09)
                      : colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(15.r),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15.r),
                    onTap: isMe ? null : () => onToggle(member.id),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.r),
                        border: Border.all(
                          color: isSelected
                              ? TourPalette.ocean.withValues(alpha: .45)
                              : colors.outlineVariant.withValues(alpha: .45),
                        ),
                      ),
                      child: Row(
                        children: [
                          TourMemberAvatar(
                            name: member.username,
                            colorIndex: member.avatarColorIndex,
                            radius: 19.r,
                          ),
                          SizedBox(width: 11.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.username,
                                  style: TextStyle(
                                    color: colors.onSurface,
                                    fontFamily: MyString.poppinsBold,
                                    fontSize: 13.sp,
                                  ),
                                ),
                                Text(
                                  isMe
                                      ? 'creator_always_included'.tr()
                                      : member.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                    fontFamily: MyString.rubikRegular,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isMe
                                ? Icons.star_rounded
                                : isSelected
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            color: isMe
                                ? TourPalette.sunset
                                : isSelected
                                ? TourPalette.ocean
                                : colors.outline,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isSubmitting || selectedCount == 0 ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: TourPalette.sunset,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              icon: isSubmitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.flight_takeoff_rounded),
              label: Text(
                'tour_create'.tr(
                  namedArgs: {'count': selectedCount.toString()},
                ),
                style: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
