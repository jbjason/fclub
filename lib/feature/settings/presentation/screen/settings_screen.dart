import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/config/router/app_router.dart';
import 'package:fclub/core/services/global_service.dart';
import 'package:fclub/core/services/locale_service.dart';
import 'package:fclub/core/util/my_dialog.dart';
import 'package:fclub/feature/auth/data/model/auth_user.dart';
import 'package:fclub/feature/auth/presentation/provider/auth_session_provider.dart';
import 'package:fclub/feature/settings/presentation/provider/settings_provider.dart';
import 'package:fclub/feature/settings/presentation/widget/settings_account_section.dart';
import 'package:fclub/feature/settings/presentation/widget/settings_header.dart';
import 'package:fclub/feature/settings/presentation/widget/settings_preferences_section.dart';
import 'package:fclub/feature/settings/presentation/widget/settings_profile_card.dart';
import 'package:fclub/feature/settings/presentation/widget/settings_sign_out_button.dart';
import 'package:fclub/feature/settings/presentation/widget/settings_support_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// Account and application preferences hub.
///
/// The screen intentionally contains composition and navigation only. Each
/// visual section owns its presentation in a dedicated widget file, while
/// persisted state continues to live in the settings and locale providers.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSessionProvider>();
    final user = session.currentUser ?? GlobalService.instance.currentUser;
    final settings = context.watch<SettingsProvider>().settings;
    final locale = context.watch<LocaleProvider>().locale;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SettingsHeader(),
                  SizedBox(height: 16.h),
                  SettingsProfileCard(
                    displayName: _displayName(user),
                    email: _email(user),
                    photoUrl: user?.photoUrl?.trim() ?? '',
                    emailVerified: user?.emailVerified ?? false,
                    onTap: () => _openProfile(context, user?.uid ?? ''),
                  ),
                  SizedBox(height: 28.h),
                  SettingsAccountSection(
                    onEditProfile: () => _openProfile(context, user?.uid ?? ''),
                  ),
                  SizedBox(height: 24.h),
                  SettingsPreferencesSection(
                    themeMode: settings.themeMode,
                    locale: locale,
                  ),
                  SizedBox(height: 24.h),
                  const SettingsSupportSection(),
                  SizedBox(height: 28.h),
                  SettingsSignOutButton(
                    isLoading: session.isSigningOut,
                    onPressed: () => _signOut(context, session),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _displayName(AuthUser? user) {
    final name = user?.displayName?.trim() ?? '';
    return name.isEmpty ? 'settings_default_user_name'.tr() : name;
  }

  String _email(AuthUser? user) {
    final email = user?.email?.trim() ?? '';
    return email.isEmpty ? 'settings_email_unavailable'.tr() : email;
  }

  void _openProfile(BuildContext context, String uid) {
    if (uid.isEmpty) {
      MyDialog().showFailedToast(
        msg: 'settings_profile_unavailable'.tr(),
        context: context,
      );
      return;
    }

    MyDialog().showComingSoonDialog(
      context: context,
      featureName: 'edit_profile'.tr(),
    );
  }

  Future<void> _signOut(
    BuildContext context,
    AuthSessionProvider session,
  ) async {
    final result = await session.signOut();
    if (!context.mounted) return;

    if (!result.isSuccess) {
      MyDialog().showFailedToast(msg: result.message, context: context);
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouteName.authGate,
      (route) => false,
    );
  }
}
