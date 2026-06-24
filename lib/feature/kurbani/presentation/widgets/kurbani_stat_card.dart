import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/kurbani_glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class KurbaniStatCard extends StatelessWidget {
  const KurbaniStatCard({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: KurbaniGlassCard(
        accentColor: color,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, size: 14.r, color: color),
            ),
            SizedBox(height: 8.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                CurrencyFormatter.format(amount),
                style: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontFamily: MyString.rubikRegular,
                fontSize: 10.sp,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
