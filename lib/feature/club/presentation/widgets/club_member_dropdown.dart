import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/services/contacts/app_contact.dart';
import 'package:fclub/feature/club/presentation/widgets/club_member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Member picker for [ClubEntryForm] — sourced from the shared contacts pool.
class ClubMemberDropdown extends StatelessWidget {
  const ClubMemberDropdown({
    super.key,
    required this.contacts,
    required this.value,
    required this.onChanged,
  });

  final List<AppContact> contacts;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Member'),
      items: contacts.map((contact) {
        return DropdownMenuItem(
          value: contact.id,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClubMemberAvatar(
                name: contact.name,
                colorIndex: contact.avatarColorIndex,
                radius: 12.r,
              ),
              SizedBox(width: 10.w),
              Flexible(
                child: Text(
                  contact.isMe ? 'You (${contact.name})' : contact.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: MyString.poppinsRegular),
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Select a member' : null,
    );
  }
}
