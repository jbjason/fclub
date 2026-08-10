import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';

import '../shared/pack_palette.dart';

class PackSessionActionBar extends StatelessWidget {
  const PackSessionActionBar({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.completed = false,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final gradient = completed
        ? const LinearGradient(colors: [PackPalette.emerald, Color(0xFF047857)])
        : PackPalette.actionGradient;
    final glow = completed ? PackPalette.emerald : PackPalette.violet;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 9, 16, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: .94),
        border: Border(
          top: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: .35),
          ),
        ),
      ),
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: glow.withValues(alpha: .28),
              blurRadius: 22,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 39,
                    height: 39,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(icon, color: Colors.white, size: 21),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: MyString.poppinsBold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .68),
                            fontFamily: MyString.rubikRegular,
                            fontSize: 9.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
