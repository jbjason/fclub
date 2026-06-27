import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/services/contacts/app_contact.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/club/data/model/payment_entry.dart';
import 'package:fclub/feature/club/presentation/widgets/club_member_avatar.dart';
import 'package:fclub/feature/club/presentation/widgets/club_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

/// A single row in the club history list. Tapping it opens the edit screen.
class ClubHistoryTile extends StatelessWidget {
  const ClubHistoryTile({
    super.key,
    required this.entry,
    required this.contact,
    required this.onTap,
  });

  final PaymentEntry entry;
  final AppContact? contact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              ClubMemberAvatar(
                name: contact?.name ?? 'Unknown',
                colorIndex: contact?.avatarColorIndex ?? 0,
                radius: 20.r,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact?.name ?? 'Unknown member',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: MyString.poppinsMedium,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      DateFormat('MMMM yyyy').format(entry.month),
                      style: TextStyle(
                        fontFamily: MyString.rubikRegular,
                        fontSize: 11.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(entry.amount),
                    style: TextStyle(
                      fontFamily: MyString.poppinsBold,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  ClubStatusBadge(status: entry.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
