import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/club/presentation/provider/club_provider.dart';
import 'package:fclub/feature/club/presentation/widgets/club_card_shell.dart';
import 'package:fclub/feature/club/presentation/widgets/shared/club_state_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ClubProjectSetupPanel extends StatefulWidget {
  const ClubProjectSetupPanel({super.key});

  @override
  State<ClubProjectSetupPanel> createState() => _ClubProjectSetupPanelState();
}

class _ClubProjectSetupPanelState extends State<ClubProjectSetupPanel> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      await context.read<ClubProvider>().createProject(
        name: _nameController.text,
        monthlyTargetPerMember: double.parse(_targetController.text),
      );
    } catch (error) {
      if (!mounted) return;
      final message = context.read<ClubProvider>().actionError ?? '$error';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClubProvider>();
    if (!provider.isGroupAdmin) {
      return ClubStatePanel(
        icon: Icons.lock_outline_rounded,
        title: 'club_create_unavailable'.tr(),
        message: 'club_create_admin_only'.tr(),
      );
    }
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 40.h),
        children: [
          const _ClubSetupHero(),
          SizedBox(height: 18.h),
          ClubCardShell(
            accent: MyColor.primary,
            padding: EdgeInsets.all(18.w),
            borderRadius: BorderRadius.circular(24.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'club_setup_form_title'.tr(),
                  style: TextStyle(
                    fontFamily: MyString.poppinsBold,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'club_setup_form_description'.tr(),
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
                    labelText: 'club_project_name'.tr(),
                    prefixIcon: const Icon(Icons.auto_awesome_rounded),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'club_project_name_required'.tr()
                      : null,
                ),
                SizedBox(height: 14.h),
                TextFormField(
                  controller: _targetController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: 'club_monthly_target_label'.tr(),
                    prefixIcon: const Icon(Icons.track_changes_rounded),
                  ),
                  validator: (value) {
                    final target = double.tryParse(value?.trim() ?? '');
                    return target == null || target <= 0
                        ? 'club_monthly_target_error'.tr()
                        : null;
                  },
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
                        : const Icon(Icons.rocket_launch_rounded),
                    label: Text('club_launch'.tr()),
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

class _ClubSetupHero extends StatelessWidget {
  const _ClubSetupHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF40158B), Color(0xFF8B3FD9), Color(0xFF078B94)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: MyColor.primary.withValues(alpha: .26),
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
              color: Colors.white.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(19.r),
              border: Border.all(color: Colors.white.withValues(alpha: .2)),
            ),
            child: Icon(Icons.savings_rounded, color: Colors.white, size: 28.r),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'club_setup_hero_kicker'.tr(),
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
                  'club_setup_hero_title'.tr(),
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
                  'club_setup_hero_subtitle'.tr(),
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
