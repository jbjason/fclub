import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/tour/presentation/provider/tour_provider.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_card_shell.dart';
import 'package:fclub/feature/tour/presentation/widgets/shared/tour_palette.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TourProjectSetupPanel extends StatefulWidget {
  const TourProjectSetupPanel({super.key});

  @override
  State<TourProjectSetupPanel> createState() => _TourProjectSetupPanelState();
}

class _TourProjectSetupPanelState extends State<TourProjectSetupPanel> {
  final _controller = TextEditingController(text: 'Tour');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    try {
      await context.read<TourProvider>().createProject(name: _controller.text);
    } catch (_) {
      if (!mounted) return;
      final key = context.read<TourProvider>().actionError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text((key ?? 'tour_error_unknown').tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TourProvider>();
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: TourCardShell(
            accent: TourPalette.ocean,
            glow: true,
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const TourCardIcon(
                      icon: Icons.travel_explore_rounded,
                      accent: TourPalette.sunset,
                      size: 56,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'tour_setup_title'.tr(),
                            style: const TextStyle(
                              fontFamily: MyString.poppinsBold,
                              fontSize: 19,
                            ),
                          ),
                          Text(
                            'tour_setup_body'.tr(),
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontFamily: MyString.rubikRegular,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                TextField(
                  controller: _controller,
                  enabled: provider.isGroupAdmin && !provider.isSubmitting,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'tour_project_name'.tr(),
                    prefixIcon: const Icon(Icons.explore_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                if (provider.isGroupAdmin)
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
                      label: Text('tour_create_space'.tr()),
                    ),
                  )
                else
                  Text(
                    'tour_setup_admin_only'.tr(),
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontFamily: MyString.rubikMedium,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
