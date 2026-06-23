import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/core/util/list_extensions.dart';
import 'package:fclub/feature/tour/data/model/extra_payment_model.dart';
import 'package:fclub/feature/tour/data/model/tour_member_model.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_empty_state.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourPaymentsTab extends StatelessWidget {
  const TourPaymentsTab({super.key, required this.payments, required this.members});

  final List<ExtraPaymentModel> payments;
  final List<TourMemberModel> members;

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return const TourEmptyState(
        icon: Icons.payments_rounded,
        message: 'No extra payments yet.',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        final member = members.firstWhereOrNull((m) => m.id == payment.memberId);
        return Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: MyColor.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: MyColor.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              TourMemberAvatar(
                name: member?.name ?? 'Unknown',
                colorIndex: member?.avatarColorIndex ?? 0,
                radius: 18.r,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member?.name ?? 'Unknown',
                      style: TextStyle(
                        fontFamily: MyString.poppinsMedium,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                    if (payment.note != null && payment.note!.isNotEmpty)
                      Text(
                        payment.note!,
                        style: TextStyle(fontSize: 11.sp, color: MyColor.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: MyColor.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '+${CurrencyFormatter.format(payment.amount)}',
                  style: TextStyle(
                    fontFamily: MyString.poppinsBold,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                    color: MyColor.success,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
