import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/feature/tour/data/models/tour_expense.dart';
import 'package:flutter/material.dart';

extension TourExpenseCategoryDisplay on TourExpenseCategory {
  String get label => switch (this) {
    TourExpenseCategory.food => 'Food',
    TourExpenseCategory.transport => 'Transport',
    TourExpenseCategory.accommodation => 'Stay',
    TourExpenseCategory.snacks => 'Snacks',
    TourExpenseCategory.misc => 'Misc',
  };

  IconData get icon => switch (this) {
    TourExpenseCategory.food => Icons.restaurant_rounded,
    TourExpenseCategory.transport => Icons.directions_bus_rounded,
    TourExpenseCategory.accommodation => Icons.hotel_rounded,
    TourExpenseCategory.snacks => Icons.icecream_rounded,
    TourExpenseCategory.misc => Icons.category_rounded,
  };

  Color get color => switch (this) {
    TourExpenseCategory.food => MyColor.primary,
    TourExpenseCategory.transport => MyColor.secondary,
    TourExpenseCategory.accommodation => MyColor.tertiary,
    TourExpenseCategory.snacks => MyColor.warning,
    TourExpenseCategory.misc => MyColor.gray500,
  };
}
