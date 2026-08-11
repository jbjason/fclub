import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/core/util/list_extensions.dart';
import 'package:fclub/feature/tour/data/models/tour_extra_payment.dart';
import 'package:fclub/feature/tour/data/models/tour_participant.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_card_shell.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_details/tour_empty_state.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourPaymentsTab extends StatelessWidget {
  const TourPaymentsTab({
    super.key,
    required this.payments,
    required this.members,
    this.onDelete,
  });

  final List<TourExtraPayment> payments;
  final List<TourParticipant> members;
  final void Function(String paymentId)? onDelete;

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return TourEmptyState(
        icon: Icons.payments_rounded,
        message: 'tour_no_payments'.tr(),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        final member = members.firstWhereOrNull(
          (m) => m.id == payment.memberId,
        );
        return TourCardShell(
          accent: MyColor.success,
          margin: EdgeInsets.only(bottom: 10.h),
          borderRadius: BorderRadius.circular(14.r),
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
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: colorScheme.onSurfaceVariant,
                        ),
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
              if (onDelete != null)
                IconButton(
                  tooltip: 'delete'.tr(),
                  onPressed: () => onDelete!(payment.id),
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: colorScheme.error,
                    size: 19.r,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
