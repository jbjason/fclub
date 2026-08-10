import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';

class PackSectionHeader extends StatelessWidget {
  const PackSectionHeader({
    super.key,
    required this.title,
    this.trailingLabel,
    this.onTrailingTap,
  });

  final String title;
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        title,
        style: const TextStyle(
          fontFamily: MyString.poppinsBold,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      const Spacer(),
      if (trailingLabel != null)
        TextButton(
          onPressed: onTrailingTap,
          child: Text(
            trailingLabel!,
            style: const TextStyle(
              fontFamily: MyString.rubikMedium,
              fontSize: 11,
            ),
          ),
        ),
    ],
  );
}
