import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fclub/feature/locker/data/models/locker_participant.dart';
import 'package:fclub/feature/locker/data/models/locker_project.dart';
import 'package:fclub/feature/locker/data/models/locker_transaction.dart';

abstract final class LockerFirestoreMapper {
  static LockerProject? project(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    if (!document.exists || data == null) return null;
    return LockerProject(
      id: document.id,
      name: _text(data['name'], fallback: 'Locker'),
      adminId: _text(data['adminId']),
    );
  }

  static LockerParticipant participant(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    return LockerParticipant(
      id: document.id,
      username: _first(data, const ['username', 'displayName'], 'Member'),
      email: _text(data['email']),
      profilePic: _first(data, const ['profilePic', 'photoUrl'], ''),
    );
  }

  static LockerTransaction transaction(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    return LockerTransaction(
      id: document.id,
      type: LockerTransactionType.fromValue(data['type']),
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      userId: _text(data['userId']),
      status: LockerTransactionStatus.fromValue(data['status']),
      submittedBy: _text(data['submittedBy']),
      submittedAt: _date(data['submittedAt']) ?? DateTime.now(),
      reviewedBy: _nullableText(data['reviewedBy']),
      reviewedAt: _date(data['reviewedAt']),
      note: _nullableText(data['note']),
    );
  }

  static String _first(
    Map<String, dynamic> data,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return fallback;
  }

  static String _text(Object? value, {String fallback = ''}) {
    return value is String && value.trim().isNotEmpty ? value.trim() : fallback;
  }

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
