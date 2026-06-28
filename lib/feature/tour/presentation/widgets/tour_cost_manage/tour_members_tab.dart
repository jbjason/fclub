import 'package:fclub/feature/tour/data/model/tour_member_model.dart';
import 'package:fclub/feature/tour/data/model/tour_summary.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_cost_manage/tour_empty_state.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_cost_manage/tour_member_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourMembersTab extends StatelessWidget {
  const TourMembersTab({
    super.key,
    required this.members,
    required this.summary,
    required this.onEditPaidToManager,
  });

  final List<TourMemberModel> members;
  final TourSummary summary;
  final void Function(TourMemberModel member) onEditPaidToManager;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const TourEmptyState(
        icon: Icons.people_rounded,
        message: 'No members yet.',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        final balance = summary.memberBalances.firstWhere(
          (b) => b.memberId == member.id,
        );
        return TourMemberCard(
          member: member,
          balance: balance,
          onTap: () => onEditPaidToManager(member),
        );
      },
    );
  }
}
