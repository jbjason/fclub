import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_gateway_backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupSessionLoadingScreen extends StatelessWidget {
  const GroupSessionLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          const Positioned.fill(child: GroupGatewayBackdrop()),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58.r,
                  height: 58.r,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [MyColor.primary, MyColor.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(19.r),
                  ),
                  child: Icon(
                    Icons.hub_rounded,
                    color: Colors.white,
                    size: 28.r,
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: 24.r,
                  height: 24.r,
                  child: const CircularProgressIndicator(
                    color: MyColor.primary,
                    strokeWidth: 2.5,
                  ),
                ),
                SizedBox(height: 13.h),
                Text(
                  'group_session_checking'.tr(),
                  style: TextStyle(
                    fontFamily: MyString.rubikRegular,
                    fontSize: 12.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
