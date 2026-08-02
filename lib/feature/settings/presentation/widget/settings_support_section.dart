import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/util/my_dialog.dart';
import 'package:fclub/feature/settings/presentation/widget/settings_section.dart';
import 'package:fclub/feature/settings/presentation/widget/settings_tile.dart';
import 'package:flutter/material.dart';

/// Help, product, and privacy destinations.
class SettingsSupportSection extends StatelessWidget {
  const SettingsSupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'support'.tr(),
      accent: MyColor.secondary,
      children: [
        SettingsTile(
          icon: Icons.help_outline_rounded,
          accent: MyColor.success,
          title: 'help_center'.tr(),
          subtitle: 'help_center_subtitle'.tr(),
          onTap: () => _showComingSoon(context, 'help_center'),
        ),
        SettingsTile(
          icon: Icons.auto_awesome_rounded,
          accent: MyColor.secondary,
          title: 'about'.tr(),
          subtitle: 'app_version'.tr(),
          onTap: () => _showComingSoon(context, 'about'),
        ),
        SettingsTile(
          icon: Icons.shield_outlined,
          accent: MyColor.primary,
          title: 'privacy_policy'.tr(),
          subtitle: 'privacy_policy_subtitle'.tr(),
          onTap: () => _showComingSoon(context, 'privacy_policy'),
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
