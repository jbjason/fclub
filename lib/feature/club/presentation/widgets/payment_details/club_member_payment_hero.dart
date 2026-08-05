import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/club/data/model/club_member_payment_summary.dart';
import 'package:fclub/feature/club/presentation/widgets/club_member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClubMemberPaymentHero extends StatelessWidget {
  const ClubMemberPaymentHero({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
    required this.summary,
  });

  final String userId;
  final String name;
  final String email;
  final ClubMemberPaymentSummary summary;

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
            color: MyColor.primary.withValues(alpha: .24),
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
                padding: EdgeInsets.all(2.r),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .92),
                ),
                child: ClubMemberAvatar(
                  name: name,
                  colorIndex: userId.hashCode.abs(),
                  radius: 24.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: MyString.poppinsBold,
                        fontSize: 16.sp,
                      ),
                    ),
                    if (email.isNotEmpty)
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .75),
                          fontFamily: MyString.rubikRegular,
                          fontSize: 10.sp,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white.withValues(alpha: .88),
                size: 22.r,
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            CurrencyFormatter.format(summary.totalPaid),
            style: TextStyle(
              color: Colors.white,
              fontFamily: MyString.poppinsBold,
              fontSize: 28.sp,
            ),
          ),
          Text(
            'club_payment_total_paid'.tr(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: .76),
              fontFamily: MyString.rubikRegular,
              fontSize: 11.sp,
            ),
          ),
          SizedBox(height: 17.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(17.r),
              border: Border.all(color: Colors.white.withValues(alpha: .15)),
            ),
            child: Row(
              children: [
                _metric(
                  label: 'club_payment_pending_amount'.tr(),
                  value: CurrencyFormatter.format(summary.totalPending),
                ),
                _divider(),
                _metric(
                  label: 'club_payment_rejected_amount'.tr(),
                  value: CurrencyFormatter.format(summary.totalRejected),
                ),
                _divider(),
                _metric(
                  label: 'club_payment_entries'.tr(),
                  value: '${summary.entryCount}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric({required String label, required String value}) {
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
              fontSize: 10.5.sp,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .68),
              fontFamily: MyString.rubikRegular,
              fontSize: 8.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 30.h,
    margin: EdgeInsets.symmetric(horizontal: 9.w),
    color: Colors.white.withValues(alpha: .18),
  );
}
