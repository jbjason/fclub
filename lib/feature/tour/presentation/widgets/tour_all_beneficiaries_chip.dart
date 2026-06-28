import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourAllBeneficiariesChip extends StatelessWidget {
  const TourAllBeneficiariesChip({
    super.key,
    required this.isSelected,
    required this.onTap,
  });

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? MyColor.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? MyColor.primary : colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          'All',
          style: TextStyle(
            fontFamily: MyString.poppinsMedium,
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
            color: isSelected ? MyColor.white : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
