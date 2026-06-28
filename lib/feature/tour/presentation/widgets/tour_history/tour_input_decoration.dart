import 'package:fclub/core/constants/my_color.dart';
import 'package:flutter/material.dart';

InputDecoration tourInputDecoration(
  BuildContext context, {
  required String hint,
  required IconData icon,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, size: 18, color: MyColor.primary),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: MyColor.primary, width: 1.5),
    ),
    filled: true,
    fillColor: colorScheme.surfaceContainerHighest,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );
}
