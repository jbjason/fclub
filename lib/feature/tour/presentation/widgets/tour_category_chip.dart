import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/tour/data/expense_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourCategoryChip extends StatelessWidget {
  const TourCategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final ExpenseCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = category.color;
    return Semantics(
      label: category.label,
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(right: 10.w),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? [color, color.withValues(alpha: 0.7)]
                  : [MyColor.surfaceContainerLow, MyColor.surfaceContainerLow],
            ),
            border: Border.all(
              color: isSelected ? color : MyColor.outlineVariant,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 10.r,
                      offset: Offset(0, 4.h),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                category.icon,
                size: 20.r,
                color: isSelected ? MyColor.white : color,
              ),
              SizedBox(height: 4.h),
              Text(
                category.label,
                style: TextStyle(
                  fontFamily: MyString.poppinsMedium,
                  fontSize: 11.sp,
                  color: isSelected ? MyColor.white : MyColor.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
