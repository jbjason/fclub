import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/tour/data/model/member_balance.dart';
import 'package:fclub/feature/tour/data/model/tour_member_model.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_breakdown_row.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourMemberSettlementCard extends StatelessWidget {
  const TourMemberSettlementCard({
    super.key,
    required this.member,
    required this.balance,
    required this.extraPaid,
  });

  final TourMemberModel member;
  final MemberBalance balance;
  final double extraPaid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final net = balance.netBalance;
    final isSettled = net.abs() < 0.5;
    final badgeColor = isSettled
        ? colorScheme.onSurfaceVariant
        : net > 0
        ? MyColor.success
        : MyColor.error;
    final badgeLabel = isSettled
        ? 'Settled'
        : net > 0
        ? 'Gets back ${CurrencyFormatter.format(net)}'
        : 'Owes ${CurrencyFormatter.format(net.abs())}';

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ExpansionTile(
        leading: TourMemberAvatar(
          name: member.name,
          colorIndex: member.avatarColorIndex,
          radius: 18.r,
        ),
        title: Text(
          member.name,
          style: TextStyle(
            fontFamily: MyString.poppinsMedium,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
        trailing: Container(
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
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
            child: Column(
              children: [
                TourBreakdownRow(label: 'Paid to manager', value: member.paidToManager),
                TourBreakdownRow(label: 'Extra payments', value: extraPaid),
                TourBreakdownRow(label: 'Spent on group', value: balance.totalSpentOnOthers),
                TourBreakdownRow(label: 'Consumed', value: balance.totalConsumedByThem),
                const Divider(),
                TourBreakdownRow(label: 'Net', value: net, isTotal: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
