import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/club/data/model/club_member.dart';
import 'package:fclub/feature/club/data/model/club_payment.dart';
import 'package:fclub/feature/club/presentation/extensions/payment_display_extension.dart';
import 'package:fclub/feature/club/presentation/widgets/club_card_shell.dart';
import 'package:fclub/feature/club/presentation/widgets/club_member_avatar.dart';
import 'package:fclub/feature/club/presentation/widgets/club_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum _PaymentAction { pending, paid, rejected, delete }

class ClubPaymentCard extends StatelessWidget {
  const ClubPaymentCard({
    super.key,
    required this.payment,
    required this.member,
    required this.isAdmin,
    required this.onStatusChanged,
    required this.onDelete,
    this.onTap,
  });

  final ClubPayment payment;
  final ClubMember? member;
  final bool isAdmin;
  final ValueChanged<PaymentStatus> onStatusChanged;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final localizations = MaterialLocalizations.of(context);
    return ClubCardShell(
      accent: payment.status.color,
      onTap: onTap,
      margin: EdgeInsets.only(bottom: 11.h),
      padding: EdgeInsets.all(14.w),
      child: Column(
        children: [
          Row(
            children: [
              ClubMemberAvatar(
                name: member?.name ?? payment.userId,
                colorIndex: payment.userId.hashCode.abs(),
                radius: 21.r,
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member?.name ?? 'club_former_member'.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: MyString.poppinsBold,
                        fontSize: 13.sp,
                        color: colors.onSurface,
                      ),
                    ),
                    Text(
                      localizations.formatMonthYear(payment.monthDate),
                      style: TextStyle(
                        fontFamily: MyString.rubikRegular,
                        fontSize: 10.sp,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(payment.amount),
                    style: TextStyle(
                      fontFamily: MyString.poppinsBold,
                      fontSize: 14.sp,
                      color: colors.onSurface,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  ClubStatusBadge(status: payment.status),
                ],
              ),
              if (isAdmin) ...[
                SizedBox(width: 2.w),
                PopupMenuButton<_PaymentAction>(
                  tooltip: 'club_review_payment'.tr(),
                  onSelected: (action) {
                    switch (action) {
                      case _PaymentAction.pending:
                        onStatusChanged(PaymentStatus.pending);
                      case _PaymentAction.paid:
                        onStatusChanged(PaymentStatus.paid);
                      case _PaymentAction.rejected:
                        onStatusChanged(PaymentStatus.rejected);
                      case _PaymentAction.delete:
                        onDelete();
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: _PaymentAction.paid,
                      child: _MenuRow(
                        icon: Icons.verified_rounded,
                        label: 'club_mark_paid'.tr(),
                        color: MyColor.success,
                      ),
                    ),
                    PopupMenuItem(
                      value: _PaymentAction.pending,
                      child: _MenuRow(
                        icon: Icons.schedule_rounded,
                        label: 'club_mark_pending'.tr(),
                        color: MyColor.warning,
                      ),
                    ),
                    PopupMenuItem(
                      value: _PaymentAction.rejected,
                      child: _MenuRow(
                        icon: Icons.cancel_rounded,
                        label: 'club_reject_payment'.tr(),
                        color: MyColor.error,
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: _PaymentAction.delete,
                      child: _MenuRow(
                        icon: Icons.delete_outline_rounded,
                        label: 'club_delete_record'.tr(),
                        color: MyColor.error,
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert_rounded),
                ),
              ],
            ],
          ),
          SizedBox(height: 11.h),
          Divider(
            height: 1,
            color: payment.status.color.withValues(alpha: .14),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              _InfoPill(
                icon: payment.paymentMethod.icon,
                label: payment.paymentMethod.localizedLabel(context),
              ),
              SizedBox(width: 7.w),
              _InfoPill(
                icon: Icons.schedule_rounded,
                label:
                    '${localizations.formatShortDate(payment.submittedAt)} · '
                    '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(payment.submittedAt))}',
              ),
              if (onTap != null) ...[
                SizedBox(width: 3.w),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 19.r,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ],
          ),
          if (payment.note != null) ...[
            SizedBox(height: 8.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                payment.note!,
                style: TextStyle(
                  fontFamily: MyString.rubikRegular,
                  fontSize: 10.sp,
                  color: colors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          if (isAdmin && payment.status == PaymentStatus.pending) ...[
            SizedBox(height: 11.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onStatusChanged(PaymentStatus.rejected),
                    icon: const Icon(Icons.close_rounded),
                    label: Text('club_reject_payment'.tr()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: MyColor.error,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => onStatusChanged(PaymentStatus.paid),
                    icon: const Icon(Icons.done_rounded),
                    label: Text('club_approve_payment'.tr()),
                    style: FilledButton.styleFrom(
                      backgroundColor: MyColor.success,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Text(label),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Flexible(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: .55),
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12.r, color: colors.onSurfaceVariant),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: MyString.rubikRegular,
                  fontSize: 8.5.sp,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
