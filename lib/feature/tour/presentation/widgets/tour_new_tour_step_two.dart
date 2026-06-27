import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/services/contacts/app_contact.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Member picker for step 2 of tour creation — choose from the shared
/// contacts pool with a checkmark list, mirroring Kurbani's equivalent step.
class TourNewTourStepTwo extends StatelessWidget {
  const TourNewTourStepTwo({
    super.key,
    required this.contacts,
    required this.meId,
    required this.selectedIds,
    required this.onToggle,
    required this.onSubmit,
  });

  final List<AppContact> contacts;
  final String? meId;
  final Set<String> selectedIds;
  final void Function(String id) onToggle;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final selectedCount = selectedIds.length + 1; // +1 for "me" (always included)

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 340.h),
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: contacts.length,
            itemBuilder: (_, i) {
              final contact = contacts[i];
              final isMe = contact.id == meId;
              final isSelected = isMe || selectedIds.contains(contact.id);

              return GestureDetector(
                onTap: isMe ? null : () => onToggle(contact.id),
                child: Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? MyColor.primary.withValues(alpha: 0.06)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? MyColor.primary.withValues(alpha: 0.3)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      TourMemberAvatar(
                        name: contact.name,
                        colorIndex: contact.avatarColorIndex,
                        radius: 18.r,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contact.name,
                              style: TextStyle(
                                fontFamily: MyString.poppinsBold,
                                fontSize: 13.sp,
                                color: MyColor.onSurface,
                              ),
                            ),
                            if (isMe)
                              Text(
                                'Creator · always included',
                                style: TextStyle(
                                  fontFamily: MyString.rubikRegular,
                                  fontSize: 10.sp,
                                  color: MyColor.tertiary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (isMe)
                        Icon(Icons.star_rounded,
                            color: MyColor.tertiary, size: 18.r)
                      else if (isSelected)
                        Icon(Icons.check_circle_rounded,
                            color: MyColor.primary, size: 20.r)
                      else
                        Icon(Icons.radio_button_unchecked_rounded,
                            color: MyColor.gray300, size: 20.r),
                    ],
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
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColor.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r)),
              ),
              child: Text(
                'Create Tour ($selectedCount members)',
                style: TextStyle(
                    fontFamily: MyString.poppinsBold, fontSize: 14.sp),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
