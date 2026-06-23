import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/core/util/my_dialog.dart';
import 'package:fclub/feature/tour/presentation/provider/tour_provider.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_balance_hero.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_member_settlement_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TourSummaryScreen extends StatelessWidget {
  const TourSummaryScreen({super.key});

  String _buildShareText(TourProvider tourProvider) {
    final summary = tourProvider.summary;
    final buffer = StringBuffer()
      ..writeln('*${tourProvider.tourName} — Settlement*')
      ..writeln('Collected: ${CurrencyFormatter.format(summary.totalCollected)}')
      ..writeln('Spent: ${CurrencyFormatter.format(summary.totalSpent)}')
      ..writeln();

    for (final member in tourProvider.members) {
      final balance = summary.memberBalances.firstWhere(
        (b) => b.memberId == member.id,
      );
      final net = balance.netBalance;
      final line = net >= 0
          ? '${member.name}: gets back ${CurrencyFormatter.format(net)}'
          : '${member.name}: owes ${CurrencyFormatter.format(net.abs())}';
      buffer.writeln(line);
    }
    return buffer.toString();
  }

  Future<void> _copyToClipboard(BuildContext context, TourProvider tourProvider) async {
    await Clipboard.setData(ClipboardData(text: _buildShareText(tourProvider)));
    if (!context.mounted) return;
    MyDialog().showSuccessToast(msg: 'Copied to clipboard.', context: context);
  }

  Future<void> _shareToWhatsApp(BuildContext context, TourProvider tourProvider) async {
    final text = Uri.encodeComponent(_buildShareText(tourProvider));
    final uri = Uri.parse('https://wa.me/?text=$text');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      MyDialog().showFailedToast(msg: 'Could not open WhatsApp.', context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tourProvider = context.watch<TourProvider>();
    final summary = tourProvider.summary;

    return Scaffold(
      backgroundColor: MyColor.surface,
      appBar: AppBar(title: const Text('Settlement Summary')),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          TourBalanceHero(balance: summary.balance, totalCollected: summary.totalCollected),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _copyToClipboard(context, tourProvider),
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copy'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareToWhatsApp(context, tourProvider),
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('WhatsApp'),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            'Member settlement',
            style: TextStyle(
              fontFamily: MyString.poppinsBold,
              fontWeight: FontWeight.w700,
              fontSize: 15.sp,
              color: MyColor.onSurface,
            ),
          ),
          SizedBox(height: 12.h),
          ...tourProvider.members.map((member) {
            final balance = summary.memberBalances.firstWhere(
              (b) => b.memberId == member.id,
            );
            final extraPaid = tourProvider.extraPayments
                .where((payment) => payment.memberId == member.id)
                .fold<double>(0, (sum, payment) => sum + payment.amount);
            return TourMemberSettlementCard(
              member: member,
              balance: balance,
              extraPaid: extraPaid,
            );
          }),
        ],
      ),
    );
  }
}
