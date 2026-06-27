import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/club/data/model/payment_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Interactive Paid/Due/Advance picker used by [ClubEntryForm].
class ClubStatusSelector extends StatelessWidget {
  const ClubStatusSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final PaymentStatus selected;
  final ValueChanged<PaymentStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: PaymentStatus.values.map((status) {
        final isSelected = status == selected;
        final color = status.color;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: status != PaymentStatus.values.last ? 8.w : 0,
            ),
            child: GestureDetector(
              onTap: () => onChanged(status),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  gradient: LinearGradient(
                    colors: isSelected
                        ? [color, color.withValues(alpha: 0.7)]
                        : [
                            color.withValues(alpha: 0.08),
                            color.withValues(alpha: 0.08),
                          ],
                  ),
                  border: Border.all(
                    color: isSelected ? color : color.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(status.icon,
                        size: 18.r, color: isSelected ? Colors.white : color),
                    SizedBox(height: 4.h),
                    Text(
                      status.label,
                      style: TextStyle(
                        fontFamily: MyString.poppinsMedium,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                        color: isSelected ? Colors.white : color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
