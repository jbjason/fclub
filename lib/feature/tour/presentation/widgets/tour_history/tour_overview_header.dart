import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/tour/presentation/widgets/shared/tour_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourOverviewHeader extends StatelessWidget {
  const TourOverviewHeader({
    super.key,
    required this.projectName,
    required this.eventCount,
    required this.hasActiveEvent,
  });

  final String projectName;
  final int eventCount;
  final bool hasActiveEvent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          colors: [TourPalette.night, Color(0xFF16314A), Color(0xFF0C6470)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: TourPalette.ocean.withValues(alpha: .22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(13.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(
              Icons.public_rounded,
              color: TourPalette.sunset,
              size: 30,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  projectName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: MyString.poppinsBold,
                    fontSize: 18.sp,
                  ),
                ),
                Text(
                  '$eventCount ${'tour_adventures'.tr()} · ${hasActiveEvent ? 'in_progress'.tr() : 'tour_ready_to_go'.tr()}',
                  style: TextStyle(
                    color: colors.surface.withValues(alpha: .72),
                    fontFamily: MyString.rubikRegular,
                    fontSize: 11.sp,
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
