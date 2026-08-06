import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_choice_divider.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_create_card.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_join_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupGatewayActions extends StatelessWidget {
  const GroupGatewayActions({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isJoining,
    required this.onPinChanged,
    required this.onJoin,
    required this.onCreate,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isJoining;
  final ValueChanged<String> onPinChanged;
  final VoidCallback onJoin;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final joinCard = GroupJoinCard(
          controller: controller,
          focusNode: focusNode,
          isJoining: isJoining,
          onChanged: onPinChanged,
          onJoin: onJoin,
        );
        final createCard = GroupCreateCard(onCreate: onCreate);

        if (constraints.maxWidth >= 760) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: joinCard),
              SizedBox(width: 16.w),
              Expanded(child: createCard),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            joinCard,
            SizedBox(height: 16.h),
            const GroupChoiceDivider(),
            SizedBox(height: 16.h),
            createCard,
          ],
        );
      },
    );
  }
}
