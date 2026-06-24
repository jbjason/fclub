import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../data/model/pack_session.dart';

/// A single card in the history list representing one completed session.
class PackHistoryTile extends StatelessWidget {
  const PackHistoryTile({required this.session, super.key});

  final PackSession session;

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        DateFormat('d MMM y  •  h:mm a').format(session.createdAt);
    final packed = session.packedCount;
    final total = session.items.length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        color: const Color(0xFF0D0B22),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 1),
      ),
      child: Row(
        children: [
          // Completed icon
          Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF10B981).withOpacity(0.15),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.35),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: const Color(0xFF10B981),
              size: 18.r,
            ),
          ),
          SizedBox(width: 12.w),
          // Name + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.name,
                  style: TextStyle(
                    fontFamily: 'Poppins_Bold',
                    fontSize: 13.sp,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  dateLabel,
                  style: TextStyle(
                    fontFamily: 'Poppins_Regular',
                    fontSize: 10.sp,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Item count badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: const Color(0xFFA855F7).withOpacity(0.12),
              border: Border.all(
                color: const Color(0xFFA855F7).withOpacity(0.3),
                width: 0.8,
              ),
            ),
            child: Text(
              '$packed / $total',
              style: TextStyle(
                fontFamily: 'Poppins_Bold',
                fontSize: 10.sp,
                color: const Color(0xFFA855F7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
