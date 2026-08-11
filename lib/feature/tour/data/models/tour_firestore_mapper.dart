import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fclub/feature/tour/data/models/tour_event.dart';
import 'package:fclub/feature/tour/data/models/tour_expense.dart';
import 'package:fclub/feature/tour/data/models/tour_extra_payment.dart';
import 'package:fclub/feature/tour/data/models/tour_participant.dart';
import 'package:fclub/feature/tour/data/models/tour_project.dart';

abstract final class TourFirestoreMapper {
  static TourProject? project(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (!document.exists || data == null) return null;
    return TourProject(
      id: document.id,
      name: _text(data['name'], fallback: 'Tour'),
      adminId: _text(data['adminId']),
      createdAt: _date(data['createdAt']),
      updatedAt: _date(data['updatedAt']),
    );
  }

  static TourEvent event(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? const <String, dynamic>{};
    return TourEvent(
      id: document.id,
      tourName: _text(data['tourName'], fallback: 'Tour'),
      decidedBudget: (data['decidedBudget'] as num?)?.toDouble() ?? 0,
      status: TourEventStatus.fromValue(data['status']),
      createdBy: _text(data['createdBy']),
      createdAt: _date(data['createdAt']),
      updatedAt: _date(data['updatedAt']),
      completedAt: _nullableDate(data['completedAt']),
    );
  }

  static TourEvent? eventOrNull(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) => document.exists && document.data() != null ? event(document) : null;

  static TourParticipant participant(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    return TourParticipant(
      id: document.id,
      username: _first(data, const ['username', 'displayName'], 'Member'),
      email: _text(data['email']).toLowerCase(),
      profilePic: _first(data, const ['profilePic', 'photoUrl'], ''),
      avatarColorIndex:
          (data['avatarColorIndex'] as num?)?.toInt() ??
          _avatarColorIndex(document.id),
      paidToManager: (data['paidToManager'] as num?)?.toDouble() ?? 0,
      joinedAt: _date(data['joinedAt']),
    );
  }

  static TourParticipantCandidate candidate(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    return TourParticipantCandidate(
      id: document.id,
      username: _first(data, const ['username', 'displayName'], 'Member'),
      email: _text(data['email']).toLowerCase(),
      profilePic: _first(data, const ['profilePic', 'photoUrl'], ''),
      avatarColorIndex:
          (data['avatarColorIndex'] as num?)?.toInt() ??
          _avatarColorIndex(document.id),
    );
  }

  static TourExpense expense(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? const <String, dynamic>{};
    return TourExpense(
      id: document.id,
      title: _text(data['title']),
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      category: TourExpenseCategory.fromValue(data['category']),
      paidByMemberId: _nullableText(data['paidByMemberId']),
      paidByAllMembers: data['paidByAllMembers'] == true,
      beneficiaryMemberIds: _stringList(data['beneficiaryMemberIds']),
      note: _nullableText(data['note']),
      createdBy: _text(data['createdBy']),
      createdAt: _date(data['createdAt']),
    );
  }

  static TourExtraPayment extraPayment(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    return TourExtraPayment(
      id: document.id,
      memberId: _text(data['memberId']),
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      note: _nullableText(data['note']),
      createdBy: _text(data['createdBy']),
      createdAt: _date(data['createdAt']),
    );
  }

  static String _first(
    Map<String, dynamic> data,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final text = _text(data[key]);
      if (text.isNotEmpty) return text;
    }
    return fallback;
  }

  static String _text(Object? value, {String fallback = ''}) =>
      value is String && value.trim().isNotEmpty ? value.trim() : fallback;

  static String? _nullableText(Object? value) {
    final text = _text(value);
    return text.isEmpty ? null : text;
  }

  static List<String> _stringList(Object? value) => value is Iterable
      ? value.whereType<String>().where((id) => id.isNotEmpty).toList()
      : const [];

  static DateTime _date(Object? value) =>
      _nullableDate(value) ?? DateTime.fromMillisecondsSinceEpoch(0);

  static DateTime? _nullableDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static int _avatarColorIndex(String id) =>
      id.codeUnits.fold<int>(0, (value, unit) => value + unit) % 8;
}
