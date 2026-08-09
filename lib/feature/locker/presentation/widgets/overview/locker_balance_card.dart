import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LockerBalanceCard extends StatelessWidget {
  const LockerBalanceCard({
    super.key,
    required this.currentCash,
    required this.collected,
    required this.spent,
    required this.participantCount,
    required this.pendingCount,
    required this.isAdmin,
  });

  final double currentCash;
  final double collected;
  final double spent;
  final int participantCount;
  final int pendingCount;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final isNegative = currentCash < 0;
    final progress = collected <= 0
        ? 0.0
        : (spent / collected).clamp(0, 1.0).toDouble();
    final healthLabel =
        (isNegative
                ? 'locker_health_overdrawn'
                : progress >= .8
                ? 'locker_health_low'
                : 'locker_health_healthy')
            .tr();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: MyColor.secondary.withValues(alpha: .24),
            blurRadius: 30,
            spreadRadius: -8,
            offset: const Offset(0, 14),
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
                      Color(0xFF071F2D),
                      Color(0xFF123257),
                      Color(0xFF5B21B6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -54.r,
              right: -36.r,
              child: _GlowOrb(
                size: 170.r,
                color: MyColor.secondary.withValues(alpha: .28),
              ),
            ),
            Positioned(
              left: -46.r,
              bottom: -72.r,
              child: _GlowOrb(
                size: 160.r,
                color: MyColor.primary.withValues(alpha: .25),
              ),
            ),
            Positioned(
              right: 18.w,
              top: 54.h,
              child: Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white.withValues(alpha: .07),
                size: 86.r,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
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
                          color: Colors.white.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(30.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .16),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.r,
                              height: 6.r,
                              decoration: const BoxDecoration(
                                color: MyColor.cyanGlow,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              healthLabel.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: MyString.rubikMedium,
                                fontSize: 8.5.sp,
                                fontWeight: FontWeight.w700,
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
                            : Icons.shield_outlined,
                        color: Colors.white.withValues(alpha: .92),
                        size: 17.r,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        (isAdmin ? 'locker_admin_vault' : 'locker_member_vault')
                            .tr(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .78),
                          fontFamily: MyString.rubikMedium,
                          fontSize: 9.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'locker_current_cash'.tr(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .68),
                      fontFamily: MyString.rubikRegular,
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    CurrencyFormatter.format(currentCash),
                    style: TextStyle(
                      color: isNegative
                          ? const Color(0xFFFFA3B5)
                          : Colors.white,
                      fontFamily: MyString.poppinsBold,
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.7,
                    ),
                  ),
                  if (isNegative)
                    Text(
                      'locker_exceeded'.tr(),
                      style: TextStyle(
                        color: const Color(0xFFFFA3B5),
                        fontFamily: MyString.rubikMedium,
                        fontSize: 9.sp,
                      ),
                    ),
                  SizedBox(height: 17.h),
                  Row(
                    children: [
                      Text(
                        'locker_used_percent'.tr(
                          namedArgs: {'percent': '${(progress * 100).round()}'},
                        ),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .72),
                          fontFamily: MyString.rubikMedium,
                          fontSize: 9.sp,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'locker_vault_summary'.tr(
                          namedArgs: {
                            'members': '$participantCount',
                            'pending': '$pendingCount',
                          },
                        ),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .6),
                          fontFamily: MyString.rubikRegular,
                          fontSize: 8.5.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 7.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 7.h,
                      backgroundColor: Colors.white.withValues(alpha: .14),
                      valueColor: AlwaysStoppedAnimation(
                        isNegative ? MyColor.error : MyColor.cyanGlow,
                      ),
                    ),
                  ),
                  SizedBox(height: 17.h),
                  Row(
                    children: [
                      Expanded(
                        child: _BalanceMetric(
                          icon: Icons.south_west_rounded,
                          label: 'collected'.tr(),
                          amount: collected,
                          color: const Color(0xFF6EE7B7),
                        ),
                      ),
                      Container(
                        height: 34.h,
                        width: 1,
                        margin: EdgeInsets.symmetric(horizontal: 14.w),
                        color: Colors.white.withValues(alpha: .15),
                      ),
                      Expanded(
                        child: _BalanceMetric(
                          icon: Icons.north_east_rounded,
                          label: 'spent'.tr(),
                          amount: spent,
                          color: const Color(0xFFFFA3B5),
                        ),
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
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

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

class _BalanceMetric extends StatelessWidget {
  const _BalanceMetric({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });

  final IconData icon;
  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 31.r,
          height: 31.r,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: color.withValues(alpha: .18)),
          ),
          child: Icon(icon, size: 15.r, color: color),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                CurrencyFormatter.format(amount),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontFamily: MyString.poppinsBold,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .58),
                  fontFamily: MyString.rubikRegular,
                  fontSize: 8.5.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
