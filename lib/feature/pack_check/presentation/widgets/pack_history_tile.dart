import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../data/model/pack_session.dart';

/// A single card in the history list representing one completed session.
///
/// Displays session name, date, and packed count.
/// [onView] opens a detail sheet; [onDelete] triggers a delete confirmation.
class PackHistoryTile extends StatelessWidget {
  const PackHistoryTile({
    required this.session,
    this.isDark = true,
    this.onView,
    this.onDelete,
    super.key,
  });

  final PackSession session;
  final bool isDark;
  final VoidCallback? onView;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        DateFormat('d MMM y  •  h:mm a').format(session.createdAt);
    final packed = session.packedCount;
    final total = session.items.length;

    final cardBg = isDark ? const Color(0xFF0D0B22) : Colors.white;
    final cardBorder = isDark
        ? Colors.white.withOpacity(0.07)
        : const Color(0xFFEDE8FF);
    final textPrimary =
        isDark ? Colors.white : const Color(0xFF1A0A3D);
    final textSecondary =
        isDark ? Colors.white38 : const Color(0xFFB8A8DC);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        color: cardBg,
        border: Border.all(color: cardBorder, width: 1),
      ),
      child: Column(
        children: [
          // ── Main row
          Padding(
            padding:
                EdgeInsets.fromLTRB(14.w, 12.h, 6.w, 10.h),
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
                // Name + date + count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.name,
                        style: TextStyle(
                          fontFamily: 'Poppins_Bold',
                          fontSize: 13.sp,
                          color: textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Text(
                            dateLabel,
                            style: TextStyle(
                              fontFamily: 'Poppins_Regular',
                              fontSize: 10.sp,
                              color: textSecondary,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.r),
                              color: const Color(0xFFA855F7)
                                  .withOpacity(isDark ? 0.12 : 0.08),
                            ),
                            child: Text(
                              '$packed/$total',
                              style: TextStyle(
                                fontFamily: 'Poppins_Bold',
                                fontSize: 9.sp,
                                color: const Color(0xFFA855F7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // ── Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionIcon(
                      icon: Icons.visibility_outlined,
                      color: const Color(0xFF06B6D4),
                      tooltip: 'View',
                      isDark: isDark,
                      onTap: onView,
                    ),
                    SizedBox(width: 2.w),
                    _ActionIcon(
                      icon: Icons.delete_outline_rounded,
                      color: const Color(0xFFF43F5E),
                      tooltip: 'Delete',
                      isDark: isDark,
                      onTap: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.isDark,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(8.r),
          child: Icon(
            icon,
            size: 18.r,
            color: color.withOpacity(onTap != null ? 0.8 : 0.3),
          ),
        ),
      ),
    );
  }
}
