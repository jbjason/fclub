import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';

class KurbaniSectionHeader extends StatelessWidget {
  const KurbaniSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: accent, size: 19),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: MyString.poppinsBold,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontFamily: MyString.rubikRegular,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
