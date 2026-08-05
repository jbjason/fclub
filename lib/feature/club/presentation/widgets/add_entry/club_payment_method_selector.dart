import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/club/presentation/extensions/payment_display_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClubPaymentMethodSelector extends StatelessWidget {
  const ClubPaymentMethodSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final PaymentMethod value;
  final ValueChanged<PaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: PaymentMethod.values
          .map((method) {
            final selected = method == value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: method == PaymentMethod.values.last ? 0 : 8.w,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16.r),
                  onTap: () => onChanged(method),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? MyColor.primary
                          : MyColor.primary.withValues(alpha: .07),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: MyColor.primary.withValues(
                          alpha: selected ? 1 : .18,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          method.icon,
                          size: 20.r,
                          color: selected ? Colors.white : MyColor.primary,
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          method.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: MyString.rubikMedium,
                            fontSize: 9.sp,
                            color: selected ? Colors.white : MyColor.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}
