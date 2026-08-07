import 'package:fclub/feature/club/presentation/provider/club_month_payment_details_provider.dart';
import 'package:fclub/feature/club/presentation/widgets/month_payment_details/club_month_payment_details_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClubMonthPaymentDetailsScreen extends StatelessWidget {
  const ClubMonthPaymentDetailsScreen({super.key, required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClubMonthPaymentDetailsProvider(month: month),
      child: const ClubMonthPaymentDetailsView(),
    );
  }
}
