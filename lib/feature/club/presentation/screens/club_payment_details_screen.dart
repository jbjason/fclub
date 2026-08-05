import 'package:fclub/feature/club/presentation/provider/club_payment_details_provider.dart';
import 'package:fclub/feature/club/presentation/widgets/payment_details/club_payment_details_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClubPaymentDetailsScreen extends StatelessWidget {
  const ClubPaymentDetailsScreen({
    super.key,
    required this.userId,
    this.fallbackName,
    this.fallbackEmail,
  });

  final String userId;
  final String? fallbackName;
  final String? fallbackEmail;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClubPaymentDetailsProvider(userId: userId),
      child: ClubPaymentDetailsView(
        userId: userId,
        fallbackName: fallbackName,
        fallbackEmail: fallbackEmail,
      ),
    );
  }
}
