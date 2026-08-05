import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_action_card_shell.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_gradient_button.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_secret_code_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupJoinCard extends StatelessWidget {
  const GroupJoinCard({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isJoining,
    required this.onChanged,
    required this.onJoin,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isJoining;
  final ValueChanged<String> onChanged;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return GroupActionCardShell(
      accent: MyColor.primary,
      icon: Icons.key_rounded,
      eyebrow: 'group_join_badge'.tr(),
      title: 'group_join_title'.tr(),
      description: 'group_join_description'.tr(),
      child: Column(
        children: [
          GroupSecretCodeField(
            controller: controller,
            focusNode: focusNode,
            enabled: !isJoining,
            onChanged: onChanged,
            onSubmitted: (_) => onJoin(),
          ),
          SizedBox(height: 15.h),
          GroupGradientButton(
            label: isJoining ? 'group_joining'.tr() : 'group_join_button'.tr(),
            icon: Icons.lock_open_rounded,
            colors: const [MyColor.primary, MyColor.secondary],
            isLoading: isJoining,
            onTap: onJoin,
          ),
        ],
      ),
    );
  }
}
