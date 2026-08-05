import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fclub/feature/club/data/model/club_payment.dart';

abstract final class ClubPaymentModel {
  static ClubPayment fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    return ClubPayment(
      id: document.id,
      userId: _text(data['userId']),
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      month: _text(data['month']),
      status: PaymentStatus.fromValue(data['status']),
      paymentMethod: PaymentMethod.fromValue(data['paymentMethod']),
      submittedBy: _text(data['submittedBy']),
      submittedAt: _date(data['submittedAt']) ?? DateTime.now(),
      reviewedBy: _nullableText(data['reviewedBy']),
      reviewedAt: _date(data['reviewedAt']),
      note: _nullableText(data['note']),
    );
  }

  static String _text(Object? value) => value is String ? value.trim() : '';

  static String? _nullableText(Object? value) {
    final text = _text(value);
    return text.isEmpty ? null : text;
  }

  static DateTime? _date(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
