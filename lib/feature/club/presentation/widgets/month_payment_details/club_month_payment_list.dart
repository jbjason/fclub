import 'package:fclub/feature/club/data/model/club_member.dart';
import 'package:fclub/feature/club/data/model/club_payment.dart';
import 'package:fclub/feature/club/presentation/widgets/monthly_overview/club_payment_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef ClubMonthPaymentStatusChanged =
    void Function(ClubPayment payment, PaymentStatus status);

class ClubMonthPaymentList extends StatelessWidget {
  const ClubMonthPaymentList({
    super.key,
    required this.payments,
    required this.isAdmin,
    required this.memberById,
    required this.onPaymentTap,
    required this.onStatusChanged,
    required this.onDelete,
  });

  final List<ClubPayment> payments;
  final bool isAdmin;
  final ClubMember? Function(String memberId) memberById;
  final ValueChanged<ClubPayment> onPaymentTap;
  final ClubMonthPaymentStatusChanged onStatusChanged;
  final ValueChanged<ClubPayment> onDelete;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 28.h),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final payment = payments[index];
          return ClubPaymentCard(
            payment: payment,
            member: memberById(payment.userId),
            isAdmin: isAdmin,
            onTap: () => onPaymentTap(payment),
            onStatusChanged: (status) => onStatusChanged(payment, status),
            onDelete: () => onDelete(payment),
          );
        }, childCount: payments.length),
      ),
    );
  }
}
