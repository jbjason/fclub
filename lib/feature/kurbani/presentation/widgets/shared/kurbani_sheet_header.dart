import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:flutter/material.dart';

class KurbaniSheetHeader extends StatelessWidget {
  const KurbaniSheetHeader({
    super.key,
    required this.kicker,
    required this.title,
    required this.icon,
    this.accent = KurbaniPalette.gold,
    this.onClose,
  });

  final String kicker;
  final String title;
  final IconData icon;
  final Color accent;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 10, 12, 18),
    decoration: const BoxDecoration(gradient: KurbaniPalette.heroGradient),
    child: Column(
      children: [
        Container(
          width: 46,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .3),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: .13)),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kicker,
                    style: TextStyle(
                      color: accent,
                      fontFamily: MyString.rubikMedium,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: MyString.poppinsBold,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onClose ?? () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded, color: Colors.white70),
            ),
          ],
        ),
      ],
    ),
  );
}
