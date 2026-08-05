import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/club/data/model/club_month_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

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
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF5A37D6), Color(0xFF7A55E8), Color(0xFF009F9A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: MyColor.primary.withValues(alpha: .25),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(color: Colors.white.withValues(alpha: .2)),
                ),
                child: Text(
                  DateFormat('MMMM yyyy').format(summary.month).toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: MyString.poppinsBold,
                    fontSize: 9.sp,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                isAdmin
                    ? Icons.admin_panel_settings_rounded
                    : Icons.groups_rounded,
                color: Colors.white,
                size: 20.r,
              ),
              SizedBox(width: 6.w),
              Text(
                isAdmin ? 'Admin view' : 'Member view',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .9),
                  fontFamily: MyString.rubikMedium,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            CurrencyFormatter.format(summary.collected),
            style: TextStyle(
              color: Colors.white,
              fontFamily: MyString.poppinsBold,
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'collected of ${CurrencyFormatter.format(summary.target)} target',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .78),
              fontFamily: MyString.rubikRegular,
              fontSize: 11.sp,
            ),
          ),
          SizedBox(height: 15.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: LinearProgressIndicator(
              value: summary.progress,
              minHeight: 8.h,
              backgroundColor: Colors.white.withValues(alpha: .18),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              _HeroMetric(
                label: 'Outstanding',
                value: CurrencyFormatter.format(summary.outstanding),
              ),
              _divider(),
              _HeroMetric(
                label: 'Pending review',
                value: CurrencyFormatter.format(summary.pending),
              ),
              _divider(),
              _HeroMetric(label: 'Members', value: '${summary.memberCount}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    height: 30.h,
    width: 1,
    margin: EdgeInsets.symmetric(horizontal: 10.w),
    color: Colors.white.withValues(alpha: .2),
  );
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontFamily: MyString.poppinsBold,
              fontSize: 11.sp,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .7),
              fontFamily: MyString.rubikRegular,
              fontSize: 8.sp,
            ),
          ),
        ],
      ),
    );
  }
}
