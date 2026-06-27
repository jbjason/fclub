import 'package:fclub/core/services/contacts/global_contacts_provider.dart';
import 'package:fclub/feature/club/data/club_hive_box.dart';
import 'package:fclub/feature/club/data/model/payment_entry.dart';
import 'package:fclub/feature/club/data/model/payment_status.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

/// Central source of truth for club payment entries. Reads/writes Hive
/// directly (no repository layer) and resolves members through the shared
/// [GlobalContactsProvider] rather than its own member model.
class ClubProvider with ChangeNotifier {
  ClubProvider(this._globalContacts)
      : _entriesBox = Hive.box<PaymentEntry>(ClubHiveBox.boxName);

  final Box<PaymentEntry> _entriesBox;
  final GlobalContactsProvider _globalContacts;
  final Uuid _uuid = const Uuid();

  /// Club started June 2025 — monthly contribution per member.
  static const double monthlyContribution = 5000;
  static final DateTime clubStartMonth = DateTime(2025, 6, 1);

  List<PaymentEntry> get entries =>
      _entriesBox.values.toList()..sort((a, b) => b.date.compareTo(a.date));

  bool get hasDemoData => _entriesBox.isNotEmpty;

  PaymentEntry? entryById(String id) => _entriesBox.get(id);

  Future<void> addEntry({
    required String contactId,
    required DateTime month,
    required double amount,
    required PaymentStatus status,
    required DateTime date,
    String? note,
  }) async {
    final entry = PaymentEntry(
      id: _uuid.v4(),
      contactId: contactId,
      month: DateTime(month.year, month.month, 1),
      amount: amount,
      statusIndex: status.index,
      date: date,
      note: note,
    );
    await _entriesBox.put(entry.id, entry);
    notifyListeners();
  }

  Future<void> updateEntry({
    required String id,
    required String contactId,
    required DateTime month,
    required double amount,
    required PaymentStatus status,
    required DateTime date,
    String? note,
  }) async {
    final entry = PaymentEntry(
      id: id,
      contactId: contactId,
      month: DateTime(month.year, month.month, 1),
      amount: amount,
      statusIndex: status.index,
      date: date,
      note: note,
    );
    await _entriesBox.put(entry.id, entry);
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    await _entriesBox.delete(id);
    notifyListeners();
  }

  /// Seeds every current member as "Paid" for each month from
  /// [clubStartMonth] through the current month.
  Future<void> seedDemoData() async {
    if (hasDemoData) return;

    final contacts = _globalContacts.contacts;
    if (contacts.isEmpty) return;

    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);

    var month = clubStartMonth;
    while (!month.isAfter(currentMonth)) {
      for (final contact in contacts) {
        final entry = PaymentEntry(
          id: _uuid.v4(),
          contactId: contact.id,
          month: month,
          amount: monthlyContribution,
          statusIndex: PaymentStatus.paid.index,
          date: DateTime(month.year, month.month, 5),
        );
        await _entriesBox.put(entry.id, entry);
      }
      month = DateTime(month.year, month.month + 1, 1);
    }
    notifyListeners();
  }
}
