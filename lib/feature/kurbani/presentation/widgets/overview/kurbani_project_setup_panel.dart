import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/kurbani/presentation/provider/kurbani_provider.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_card_shell.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_state_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class KurbaniProjectSetupPanel extends StatefulWidget {
  const KurbaniProjectSetupPanel({super.key});

  @override
  State<KurbaniProjectSetupPanel> createState() =>
      _KurbaniProjectSetupPanelState();
}

class _KurbaniProjectSetupPanelState extends State<KurbaniProjectSetupPanel> {
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
      await context.read<KurbaniProvider>().createProject(
        name: _nameController.text,
      );
    } catch (_) {
      if (!mounted) return;
      final key = context.read<KurbaniProvider>().actionError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text((key ?? 'kurbani_error_unknown').tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KurbaniProvider>();
    if (!provider.isGroupAdmin) {
      return KurbaniStatePanel(
        icon: Icons.admin_panel_settings_outlined,
        title: 'kurbani_create_unavailable'.tr(),
        message: 'kurbani_create_admin_only'.tr(),
      );
    }
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: KurbaniPalette.heroGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: KurbaniPalette.emerald.withValues(alpha: .22),
                  blurRadius: 30,
                  spreadRadius: -8,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(21),
                  ),
                  child: const Icon(
                    Icons.nightlight_round,
                    color: KurbaniPalette.gold,
                    size: 31,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'kurbani_setup_kicker'.tr(),
                        style: const TextStyle(
                          color: KurbaniPalette.gold,
                          fontFamily: MyString.rubikMedium,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'kurbani_setup_title'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: MyString.poppinsBold,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'kurbani_setup_subtitle'.tr(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .68),
                          fontFamily: MyString.rubikRegular,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          KurbaniCardShell(
            accent: KurbaniPalette.gold,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'kurbani_project_details'.tr(),
                  style: const TextStyle(
                    fontFamily: MyString.poppinsBold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'kurbani_project_details_hint'.tr(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontFamily: MyString.rubikRegular,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 17),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'kurbani_project_name'.tr(),
                    prefixIcon: const Icon(Icons.mosque_rounded),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'kurbani_project_name_required'.tr()
                      : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: provider.isSubmitting ? null : _create,
                    icon: provider.isSubmitting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome_rounded),
                    label: Text('kurbani_launch_project'.tr()),
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
