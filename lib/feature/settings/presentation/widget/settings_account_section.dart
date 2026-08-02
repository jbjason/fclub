import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/util/my_dialog.dart';
import 'package:fclub/feature/settings/presentation/widget/settings_section.dart';
import 'package:fclub/feature/settings/presentation/widget/settings_tile.dart';
import 'package:flutter/material.dart';

/// Account-related settings actions.
class SettingsAccountSection extends StatelessWidget {
  const SettingsAccountSection({super.key, required this.onEditProfile});

  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'account'.tr(),
      accent: MyColor.tertiary,
      children: [
        SettingsTile(
          icon: Icons.person_outline_rounded,
          accent: MyColor.tertiary,
          title: 'edit_profile'.tr(),
          subtitle: 'edit_profile_subtitle'.tr(),
          onTap: onEditProfile,
        ),
        SettingsTile(
          icon: Icons.lock_outline_rounded,
          accent: MyColor.primary,
          title: 'change_password'.tr(),
          subtitle: 'change_password_subtitle'.tr(),
          onTap: () => _showComingSoon(context, 'change_password'),
        ),
        SettingsTile(
          icon: Icons.notifications_none_rounded,
          accent: MyColor.warning,
          title: 'notifications'.tr(),
          subtitle: 'notifications_subtitle'.tr(),
          onTap: () => _showComingSoon(context, 'notifications'),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String featureKey) {
    MyDialog().showComingSoonDialog(
      context: context,
      featureName: featureKey.tr(),
    );
  }
}
