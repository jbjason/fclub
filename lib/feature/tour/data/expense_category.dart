import 'package:fclub/core/constants/my_color.dart';
import 'package:flutter/material.dart';

enum ExpenseCategory { food, transport, accommodation, snacks, misc }

extension ExpenseCategoryX on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.accommodation:
        return 'Stay';
      case ExpenseCategory.snacks:
        return 'Snacks';
      case ExpenseCategory.misc:
        return 'Misc';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.restaurant_rounded;
      case ExpenseCategory.transport:
        return Icons.directions_bus_rounded;
      case ExpenseCategory.accommodation:
        return Icons.hotel_rounded;
      case ExpenseCategory.snacks:
        return Icons.icecream_rounded;
      case ExpenseCategory.misc:
        return Icons.category_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return MyColor.primary;
      case ExpenseCategory.transport:
        return MyColor.secondary;
      case ExpenseCategory.accommodation:
        return MyColor.tertiary;
      case ExpenseCategory.snacks:
        return MyColor.warning;
      case ExpenseCategory.misc:
        return MyColor.gray500;
    }
  }
}
