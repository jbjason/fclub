import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/model/pack_session.dart';

/// Compact session nameplate shown while a session is active or in draft.
///
/// New-session creation is intentionally absent here — the user must
/// complete the active session first, then create from the history view.
class PackSessionHeader extends StatelessWidget {
  const PackSessionHeader({
    required this.session,
    this.isDraft = false,
    super.key,
  });

  final PackSession session;

  /// True when the session has not been saved to storage yet.
  final bool isDraft;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: Colors.white.withOpacity(0.05),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          child: Row(
            children: [
              // Session icon
              Container(
                width: 36.r,
                height: 36.r,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFA855F7), Color(0xFF06B6D4)],
                  ),
                ),
                child: Icon(Icons.backpack_rounded,
                    color: Colors.white, size: 18.r),
              ),
              SizedBox(width: 10.w),
              // Session name + item count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.name,
                      style: TextStyle(
                        fontFamily: 'Poppins_Bold',
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${session.packedCount} of ${session.items.length} items selected',
                      style: TextStyle(
                        fontFamily: 'Poppins_Regular',
                        fontSize: 11.sp,
                        color: const Color(0xFFA855F7),
                      ),
                    ),
                  ],
                ),
              ),
              // "Draft" / "Active" pill
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: isDraft
                      ? const Color(0xFFF59E0B).withOpacity(0.12)
                      : const Color(0xFF10B981).withOpacity(0.12),
                  border: Border.all(
                    color: isDraft
                        ? const Color(0xFFF59E0B).withOpacity(0.35)
                        : const Color(0xFF10B981).withOpacity(0.35),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5.r,
                      height: 5.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDraft
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF10B981),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      isDraft ? 'Draft' : 'Active',
                      style: TextStyle(
                        fontFamily: 'Poppins_Medium',
                        fontSize: 10.sp,
                        color: isDraft
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
