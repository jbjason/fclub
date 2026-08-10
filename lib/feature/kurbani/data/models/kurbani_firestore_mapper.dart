import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_animal_part.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_event.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_expense.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_participant.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_project.dart';

abstract final class KurbaniFirestoreMapper {
  static KurbaniProject? project(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    if (!document.exists || data == null) return null;
    return KurbaniProject(
      id: document.id,
      name: _text(data['name'], fallback: 'Kurbani'),
      adminId: _text(data['adminId']),
      status: KurbaniProjectStatus.fromValue(data['status']),
      createdAt: _date(data['createdAt']),
    );
  }

  static KurbaniEvent event(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? const <String, dynamic>{};
    return KurbaniEvent(
      id: document.id,
      name: _text(data['name'], fallback: 'Kurbani'),
      status: KurbaniEventStatus.fromValue(data['status']),
      createdAt: _date(data['createdAt']),
      updatedAt: _date(data['updatedAt']),
    );
  }

  static KurbaniEvent? eventOrNull(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    if (!document.exists || document.data() == null) return null;
    return event(document);
  }

  static KurbaniParticipant participant(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    return KurbaniParticipant(
      id: document.id,
      username: _first(data, const ['username', 'displayName'], 'Member'),
      email: _text(data['email']).toLowerCase(),
      profilePic: _first(data, const ['profilePic', 'photoUrl'], ''),
      contribution: (data['contribution'] as num?)?.toDouble() ?? 0,
      paidStatus: KurbaniPaidStatus.fromValue(data['paidStatus']),
      joinedAt: _date(data['joinedAt']),
    );
  }

  static KurbaniExpense expense(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    return KurbaniExpense(
      id: document.id,
      title: _text(data['title']),
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      paidByMemberId: _nullableText(data['paidByMemberId']),
      paidByAllMembers: data['paidByAllMembers'] == true,
      note: _nullableText(data['note']),
      createdBy: _text(data['createdBy']),
      createdAt: _date(data['createdAt']),
    );
  }

  static KurbaniAnimalPart animalPart(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    return KurbaniAnimalPart(
      id: document.id,
      name: _text(data['name']),
      weightKg: (data['weightKg'] as num?)?.toDouble() ?? 0,
      assignedToUid: _nullableText(data['assignedToUid']),
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

  static DateTime _date(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
