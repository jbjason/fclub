import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/tour/data/models/tour_event.dart';
import 'package:fclub/feature/tour/presentation/widgets/shared/tour_palette.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_card_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class TourHistoryCard extends StatelessWidget {
  const TourHistoryCard({
    super.key,
    required this.event,
    required this.canManage,
    required this.onOpen,
    required this.onDelete,
  });

  final TourEvent event;
  final bool canManage;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isCancelled = event.status == TourEventStatus.cancelled;
    final accent = isCancelled ? colors.outline : TourPalette.lagoon;
    return TourCardShell(
      accent: accent,
      onTap: onOpen,
      margin: EdgeInsets.only(bottom: 11.h),
      borderRadius: BorderRadius.circular(18.r),
      padding: EdgeInsets.all(14.r),
      child: Row(
        children: [
          TourCardIcon(
            icon: isCancelled
                ? Icons.flight_land_rounded
                : Icons.landscape_rounded,
            accent: accent,
            size: 42,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.tourName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontFamily: MyString.poppinsBold,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${DateFormat('d MMM y').format(event.completedAt ?? event.createdAt)}  ·  ${CurrencyFormatter.format(event.decidedBudget)}',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontFamily: MyString.rubikRegular,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .11),
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Text(
              event.status.value.toUpperCase(),
              style: TextStyle(
                color: accent,
                fontFamily: MyString.poppinsBold,
                fontSize: 8.sp,
                letterSpacing: .7,
              ),
            ),
          ),
          if (canManage)
            IconButton(
              tooltip: 'Delete',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded, size: 19),
            )
          else
            const TourCardArrow(accent: TourPalette.ocean),
        ],
      ),
    );
  }
}
