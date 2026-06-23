import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/tour/data/model/member_balance.dart';
import 'package:fclub/feature/tour/data/model/tour_member_model.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourMemberCard extends StatelessWidget {
  const TourMemberCard({
    super.key,
    required this.member,
    required this.balance,
    this.onTap,
  });

  final TourMemberModel member;
  final MemberBalance balance;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final net = balance.netBalance;
    final isSettled = net.abs() < 0.5;
    final badgeColor = isSettled
        ? MyColor.gray400
        : net > 0
        ? MyColor.success
        : MyColor.error;
    final badgeLabel = isSettled
        ? 'Settled'
        : net > 0
        ? 'Gets back ${CurrencyFormatter.format(net)}'
        : 'Owes ${CurrencyFormatter.format(net.abs())}';

    return Material(
      color: MyColor.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: MyColor.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              TourMemberAvatar(
                name: member.name,
                colorIndex: member.avatarColorIndex,
                radius: 20.r,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: TextStyle(
                        fontFamily: MyString.poppinsMedium,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: MyColor.onSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Paid to manager: ${CurrencyFormatter.format(member.paidToManager)}',
                      style: TextStyle(
                        fontFamily: MyString.poppinsRegular,
                        fontSize: 11.sp,
                        color: MyColor.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    fontFamily: MyString.poppinsBold,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
