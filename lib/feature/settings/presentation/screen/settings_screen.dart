import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fclub/config/router/app_router.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/services/global_service.dart';
import 'package:fclub/core/util/my_dialog.dart';
import 'package:fclub/feature/auth/presentation/provider/auth_session_provider.dart';
import 'package:fclub/feature/settings/presentation/widget/settings_section.dart';
import 'package:fclub/feature/settings/presentation/widget/settings_tile.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AuthSessionProvider>(
          builder: (context, session, _) {
            final user =
                session.currentUser ?? GlobalService.instance.currentUser;
            final uid = user?.uid ?? '';
            final rawEmail = user?.email?.trim() ?? '';
            final rawPhotoUrl = user?.photoUrl?.trim() ?? '';
            final email = rawEmail.isNotEmpty ? rawEmail : 'user@opmedia.com';
            final emailVerified = user?.emailVerified ?? false;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 22.h),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SettingsHeader(),
                      SizedBox(height: 24.h),
                      _ProfileCard(
                        email: email,
                        photoUrl: rawPhotoUrl,
                        emailVerified: emailVerified,
                      ),
                      SizedBox(height: 28.h),
                      SettingsSection(
                        title: 'Account',
                        children: [
                          SettingsTile(
                            icon: Icons.person_outline_rounded,
                            iconColor: const Color(0xFFEC4899),
                            title: 'Edit Profile',
                            subtitle: 'Update name, photo & details',
                            onTap: () {
                              if (uid.isEmpty) {
                                MyDialog().showFailedToast(
                                  msg:
                                      'Unable to open profile editor right now.',
                                  context: context,
                                );
                                return;
                              }
                              MyDialog().showComingSoonDialog(
                                context: context,
                                featureName: 'Edit Profile',
                              );
                            },
                          ),
                          SettingsTile(
                            icon: Icons.lock_outline_rounded,
                            iconColor: const Color(0xFFDB2777),
                            title: 'Change Password',
                            subtitle: 'Update your security credentials',
                            onTap: () => MyDialog().showComingSoonDialog(
                              context: context,
                              featureName: 'Change Password',
                            ),
                          ),
                          SettingsTile(
                            icon: Icons.notifications_none_rounded,
                            iconColor: const Color(0xFFF97316),
                            title: 'Notifications',
                            subtitle: 'Push, email & in-app alerts',
                            onTap: () => MyDialog().showComingSoonDialog(
                              context: context,
                              featureName: 'Notifications',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      SettingsSection(
                        title: 'Preferences',
                        children: [
                          SettingsTile(
                            icon: Icons.palette_outlined,
                            iconColor: const Color(0xFFDB2777),
                            title: 'Appearance',
                            subtitle: 'Theme & display options',
                            onTap: () => MyDialog().showComingSoonDialog(
                              context: context,
                              featureName: 'Appearance',
                            ),
                          ),
                          SettingsTile(
                            icon: Icons.language_rounded,
                            iconColor: const Color(0xFF16A34A),
                            title: 'Language',
                            subtitle: 'English (US)',
                            onTap: () => MyDialog().showComingSoonDialog(
                              context: context,
                              featureName: 'Language',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      SettingsSection(
                        title: 'Support',
                        children: [
                          SettingsTile(
                            icon: Icons.help_outline_rounded,
                            iconColor: const Color(0xFF0F766E),
                            title: 'Help Center',
                            subtitle: 'FAQs & documentation',
                            onTap: () => MyDialog().showComingSoonDialog(
                              context: context,
                              featureName: 'Help Center',
                            ),
                          ),
                          SettingsTile(
                            icon: Icons.info_outline_rounded,
                            iconColor: const Color(0xFF475569),
                            title: 'About Op Media',
                            subtitle: 'Version 1.0.0',
                            onTap: () => MyDialog().showComingSoonDialog(
                              context: context,
                              featureName: 'About Op Media',
                            ),
                          ),
                          SettingsTile(
                            icon: Icons.shield_outlined,
                            iconColor: const Color(0xFF2563EB),
                            title: 'Privacy Policy',
                            subtitle: 'How we handle your data',
                            onTap: () => MyDialog().showComingSoonDialog(
                              context: context,
                              featureName: 'Privacy Policy',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 28.h),
                      _SignOutButton(session: session),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      color: MyColor.gray900,
                      fontFamily: MyString.poppinsBold,
                      fontSize: 29.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Manage your account & preferences.',
                    style: TextStyle(
                      color: MyColor.gray600,
                      fontFamily: MyString.rubikRegular,
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.email,
    required this.photoUrl,
    required this.emailVerified,
  });
  final String email;
  final String photoUrl;
  final bool emailVerified;


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4C0519), Color(0xFFEC4899), Color(0xFFDB2777)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withValues(alpha: 0.25),
            offset: Offset(0, 12.h),
            blurRadius: 28.r,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62.r,
            height: 62.r,
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(
              color: MyColor.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: MyColor.white.withValues(alpha: 0.35)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17.r),
              child: photoUrl.isNotEmpty
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _InitialsAvatar(initials: "FC"),
                    )
                  : _InitialsAvatar(initials: "FC"),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "F Club User",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: MyColor.white,
                    fontFamily: MyString.poppinsBold,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: MyColor.white.withValues(alpha: 0.78),
                    fontFamily: MyString.rubikRegular,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: MyColor.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: MyColor.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        emailVerified
                            ? Icons.verified_rounded
                            : Icons.error_outline_rounded,
                        color: emailVerified
                            ? const Color(0xFF34D399)
                            : const Color(0xFFFBBF24),
                        size: 14.r,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        emailVerified ? 'Verified Account' : 'Unverified Email',
                        style: TextStyle(
                          color: MyColor.white.withValues(alpha: 0.9),
                          fontFamily: MyString.poppinsMedium,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: MyColor.white.withValues(alpha: 0.6),
            size: 24.r,
          ),
        ],
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: MyColor.white.withValues(alpha: 0.12),
      child: Text(
        initials,
        style: TextStyle(
          color: MyColor.white,
          fontFamily: MyString.poppinsBold,
          fontWeight: FontWeight.w700,
          fontSize: 22.sp,
        ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.session});

  final AuthSessionProvider session;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MyColor.errorContainer,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: session.isSigningOut
            ? null
            : () async {
                final result = await session.signOut();
                if (!context.mounted) return;

                if (!result.isSuccess) {
                  MyDialog().showFailedToast(
                    msg: result.message,
                    context: context,
                  );
                  return;
                }

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRouteName.authGate,
                  (route) => false,
                );
              },
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: MyColor.error.withValues(alpha: 0.12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              session.isSigningOut
                  ? SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        color: MyColor.error,
                      ),
                    )
                  : Icon(
                      Icons.logout_rounded,
                      color: MyColor.error,
                      size: 20.r,
                    ),
              SizedBox(width: 12.w),
              Text(
                session.isSigningOut ? 'Signing Out...' : 'Sign Out',
                style: TextStyle(
                  color: MyColor.error,
                  fontFamily: MyString.poppinsBold,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
