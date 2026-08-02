import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_action_card_shell.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_feature_chip.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupCreateCard extends StatelessWidget {
  const GroupCreateCard({super.key, required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return GroupActionCardShell(
      accent: MyColor.tertiary,
      icon: Icons.add_rounded,
      eyebrow: 'group_create_badge'.tr(),
      title: 'group_create_title'.tr(),
      description: 'group_create_description'.tr(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              GroupFeatureChip(
                icon: Icons.visibility_off_rounded,
                label: 'group_create_private'.tr(),
                accent: MyColor.primary,
              ),
              GroupFeatureChip(
                icon: Icons.person_add_alt_1_rounded,
                label: 'group_create_invite'.tr(),
                accent: MyColor.secondary,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          GroupGradientButton(
            label: 'group_create_button'.tr(),
            icon: Icons.add_circle_outline_rounded,
            colors: const [MyColor.primary, MyColor.tertiary],
            onTap: onCreate,
          ),
        ],
      ),
    );
  }
}
