import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_member_balance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Avatar gradient palette — 7 colours for 7 kurbani shares.
const List<List<Color>> kurbaniAvatarGradients = [
  [Color(0xFF6D28D9), Color(0xFFA855F7)], // violet
  [Color(0xFF0891B2), Color(0xFF06B6D4)], // cyan
  [Color(0xFFDC2626), Color(0xFFF43F5E)], // rose
  [Color(0xFF059669), Color(0xFF10B981)], // emerald
  [Color(0xFFD97706), Color(0xFFF59E0B)], // amber
  [Color(0xFF7C3AED), Color(0xFF8B5CF6)], // purple
  [Color(0xFF1D4ED8), Color(0xFF3B82F6)], // blue
];

class KurbaniMemberCard extends StatelessWidget {
  const KurbaniMemberCard({super.key, required this.balance});

  final KurbaniMemberBalance balance;

  static const _emerald = Color(0xFF10B981);
  static const _rose = Color(0xFFEF4444);
  static const _amber = Color(0xFFF59E0B);

  Color get _netColor {
    if (balance.isOwedByGroup) return _emerald;
    if (balance.owesGroup) return _rose;
    return _amber;
  }

  String get _netLabel {
    if (balance.isOwedByGroup) return 'Gets ${CurrencyFormatter.format(balance.net)}';
    if (balance.owesGroup) return 'Owes ${CurrencyFormatter.format(balance.net.abs())}';
    return 'Settled ✓';
  }

  IconData get _netIcon {
    if (balance.isOwedByGroup) return Icons.arrow_downward_rounded;
    if (balance.owesGroup) return Icons.arrow_upward_rounded;
    return Icons.check_circle_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final gradients = kurbaniAvatarGradients[
        balance.avatarColorIndex % kurbaniAvatarGradients.length];
    final initials = _initials(balance.memberName);
    final color = _netColor;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradients,
              ),
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Name + contributions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  balance.memberName,
                  style: TextStyle(
                    fontFamily: MyString.poppinsBold,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  'Paid ${CurrencyFormatter.format(balance.contributed)} · Expenses ${CurrencyFormatter.format(balance.paidExpenses)}',
                  style: TextStyle(
                    fontFamily: MyString.rubikRegular,
                    fontSize: 10.sp,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Net badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_netIcon, size: 11.r, color: color),
                SizedBox(width: 4.w),
                Text(
                  _netLabel,
                  style: TextStyle(
                    fontFamily: MyString.poppinsBold,
                    fontSize: 10.sp,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }
}
