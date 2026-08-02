import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_language_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupGatewayHeader extends StatelessWidget {
  const GroupGatewayHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 42.r,
          height: 42.r,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [MyColor.primary, MyColor.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: MyColor.primary.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(Icons.hub_rounded, color: Colors.white, size: 21.r),
        ),
        SizedBox(width: 11.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fundora',
              style: TextStyle(
                fontFamily: MyString.poppinsBold,
                fontWeight: FontWeight.w700,
                fontSize: 17.sp,
                color: colorScheme.onSurface,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              'group_gateway_brand_label'.tr(),
              style: TextStyle(
                fontFamily: MyString.rubikMedium,
                fontSize: 8.5.sp,
                color: MyColor.primary,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const Spacer(),
        const GroupLanguageToggle(),
      ],
    );
  }
}
