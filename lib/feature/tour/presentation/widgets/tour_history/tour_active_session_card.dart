import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/tour/data/models/tour_event.dart';
import 'package:fclub/feature/tour/presentation/widgets/shared/tour_palette.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_card_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourActiveSessionCard extends StatelessWidget {
  const TourActiveSessionCard({
    super.key,
    required this.event,
    required this.canManage,
    required this.onResume,
    required this.onFinish,
    required this.onDelete,
  });

  final TourEvent event;
  final bool canManage;
  final VoidCallback onResume;
  final VoidCallback onFinish;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TourCardShell(
      accent: TourPalette.ocean,
      glow: true,
      onTap: onResume,
      borderRadius: BorderRadius.circular(22.r),
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          const TourCardIcon(
            icon: Icons.flight_rounded,
            accent: TourPalette.sunset,
            size: 48,
          ),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7.r,
                      height: 7.r,
                      decoration: const BoxDecoration(
                        color: TourPalette.lagoon,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'in_progress'.tr().toUpperCase(),
                      style: TextStyle(
                        color: TourPalette.lagoon,
                        fontFamily: MyString.poppinsBold,
                        fontSize: 9.sp,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  event.tourName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontFamily: MyString.poppinsBold,
                    fontSize: 15.sp,
                  ),
                ),
                Text(
                  '${'tour_budget_short'.tr()} ${CurrencyFormatter.format(event.decidedBudget)}',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontFamily: MyString.rubikRegular,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: onResume,
            style: FilledButton.styleFrom(
              backgroundColor: TourPalette.ocean,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              visualDensity: VisualDensity.compact,
            ),
            child: Text('resume'.tr()),
          ),
          if (canManage)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: colors.onSurfaceVariant,
              ),
              onSelected: (value) =>
                  value == 'finish' ? onFinish() : onDelete(),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'finish',
                  child: Text('finish_session'.tr()),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('delete_session'.tr()),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
