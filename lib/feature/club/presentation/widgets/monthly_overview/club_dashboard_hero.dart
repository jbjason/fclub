import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/club/data/model/club_month_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClubDashboardHero extends StatelessWidget {
  const ClubDashboardHero({
    super.key,
    required this.summary,
    required this.isAdmin,
  });

  final ClubMonthSummary summary;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: MyColor.primary.withValues(alpha: .3),
            blurRadius: 32,
            spreadRadius: -8,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF36117A),
                      Color(0xFF7138D0),
                      Color(0xFF007F88),
                    ],
                    stops: [0, .55, 1],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -42.r,
              top: -55.r,
              child: _HeroOrb(
                size: 190.r,
                color: MyColor.cyanGlow.withValues(alpha: .26),
              ),
            ),
            Positioned(
              left: -62.r,
              bottom: -84.r,
              child: _HeroOrb(
                size: 200.r,
                color: MyColor.violetGlow.withValues(alpha: .25),
              ),
            ),
            Positioned(
              right: 17.w,
              top: 54.h,
              child: Transform.rotate(
                angle: -.12,
                child: Icon(
                  Icons.savings_rounded,
                  color: Colors.white.withValues(alpha: .075),
                  size: 96.r,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(19.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .14),
                          borderRadius: BorderRadius.circular(30.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .18),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.white.withValues(alpha: .88),
                              size: 12.r,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              DateFormat(
                                'MMMM yyyy',
                                context.locale.toString(),
                              ).format(summary.month).toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: MyString.poppinsBold,
                                fontSize: 8.5.sp,
                                letterSpacing: .8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        isAdmin
                            ? Icons.verified_user_rounded
                            : Icons.groups_rounded,
                        color: Colors.white,
                        size: 18.r,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        (isAdmin ? 'club_admin_view' : 'club_member_view').tr(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .86),
                          fontFamily: MyString.rubikMedium,
                          fontSize: 9.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 17.h),
                  Text(
                    'club_total_collected'.tr(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .62),
                      fontFamily: MyString.rubikMedium,
                      fontSize: 8.5.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.3,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    CurrencyFormatter.format(summary.collected),
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: MyString.poppinsBold,
                      fontSize: 29.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.7,
                    ),
                  ),
                  Text(
                    'club_collective_target'.tr(
                      namedArgs: {
                        'amount': CurrencyFormatter.format(summary.target),
                      },
                    ),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .72),
                      fontFamily: MyString.rubikRegular,
                      fontSize: 10.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Text(
                        'club_funded_percent'.tr(
                          namedArgs: {
                            'percent': '${(summary.progress * 100).round()}',
                          },
                        ),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .78),
                          fontFamily: MyString.rubikMedium,
                          fontSize: 9.sp,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'club_members_count'.tr(
                          namedArgs: {'count': '${summary.memberCount}'},
                        ),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .62),
                          fontFamily: MyString.rubikRegular,
                          fontSize: 8.5.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 7.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: LinearProgressIndicator(
                      value: summary.progress,
                      minHeight: 7.h,
                      backgroundColor: Colors.white.withValues(alpha: .16),
                      valueColor: const AlwaysStoppedAnimation(
                        MyColor.cyanGlow,
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Row(
                    children: [
                      _HeroMetric(
                        icon: Icons.schedule_rounded,
                        label: 'club_outstanding'.tr(),
                        value: CurrencyFormatter.format(summary.outstanding),
                        color: const Color(0xFFFFC2D0),
                      ),
                      _divider(),
                      _HeroMetric(
                        icon: Icons.hourglass_top_rounded,
                        label: 'club_pending_review'.tr(),
                        value: CurrencyFormatter.format(summary.pending),
                        color: const Color(0xFFFFD58A),
                      ),
                      _divider(),
                      _HeroMetric(
                        icon: Icons.people_alt_rounded,
                        label: 'club_members'.tr(),
                        value: '${summary.memberCount}',
                        color: const Color(0xFF8EF2F6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
    height: 34.h,
    width: 1,
    margin: EdgeInsets.symmetric(horizontal: 8.w),
    color: Colors.white.withValues(alpha: .16),
  );
}

class _HeroOrb extends StatelessWidget {
  const _HeroOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 28.r,
            height: 28.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Icon(icon, color: color, size: 13.r),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontFamily: MyString.poppinsBold,
                    fontSize: 9.5.sp,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .58),
                    fontFamily: MyString.rubikRegular,
                    fontSize: 7.3.sp,
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
