import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/locker/presentation/provider/locker_provider.dart';
import 'package:fclub/feature/locker/presentation/widgets/locker_card_shell.dart';
import 'package:fclub/feature/locker/presentation/widgets/shared/locker_state_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class LockerProjectSetupPanel extends StatefulWidget {
  const LockerProjectSetupPanel({super.key});

  @override
  State<LockerProjectSetupPanel> createState() =>
      _LockerProjectSetupPanelState();
}

class _LockerProjectSetupPanelState extends State<LockerProjectSetupPanel> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      await context.read<LockerProvider>().createProject(
        name: _nameController.text,
      );
    } catch (error) {
      if (!mounted) return;
      final message = context.read<LockerProvider>().actionError ?? '$error';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LockerProvider>();
    if (!provider.isGroupAdmin) {
      return LockerStatePanel(
        icon: Icons.lock_outline_rounded,
        title: 'locker_create_unavailable'.tr(),
        message: 'locker_create_admin_only'.tr(),
      );
    }
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 40.h),
        children: [
          const _LockerSetupHero(),
          SizedBox(height: 18.h),
          LockerCardShell(
            accent: MyColor.secondary,
            borderRadius: BorderRadius.circular(24.r),
            padding: EdgeInsets.all(18.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'locker_setup_form_title'.tr(),
                  style: TextStyle(
                    fontFamily: MyString.poppinsBold,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'locker_setup_form_description'.tr(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontFamily: MyString.rubikRegular,
                    fontSize: 10.5.sp,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 18.h),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'locker_project_name'.tr(),
                    prefixIcon: const Icon(
                      Icons.account_balance_wallet_rounded,
                    ),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'locker_project_name_required'.tr()
                      : null,
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: provider.isSubmitting ? null : _create,
                    icon: provider.isSubmitting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.lock_open_rounded),
                    label: Text('locker_open'.tr()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LockerSetupHero extends StatelessWidget {
  const _LockerSetupHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF071F2D), Color(0xFF164564), Color(0xFF5B21B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: MyColor.secondary.withValues(alpha: .24),
            blurRadius: 28,
            spreadRadius: -7,
            offset: const Offset(0, 13),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58.r,
            height: 58.r,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(19.r),
              border: Border.all(color: Colors.white.withValues(alpha: .19)),
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              color: Colors.white,
              size: 28.r,
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'locker_setup_hero_kicker'.tr(),
                  style: TextStyle(
                    color: MyColor.cyanGlow,
                    fontFamily: MyString.rubikMedium,
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'locker_setup_hero_title'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: MyString.poppinsBold,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.12,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  'locker_setup_hero_subtitle'.tr(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .7),
                    fontFamily: MyString.rubikRegular,
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
