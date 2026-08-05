import 'package:fclub/core/services/contacts/app_contact.dart';
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

  /// Only these real users are Fundora Club members — the club is a subset
  /// of the full shared contacts pool, not everyone in it.
  static const Set<String> _clubMemberIds = {
    '4f3tRdRx0Q5h9vKigqRm',
    '7dkX7S5BdEScw5OMPTaN',
    '9EzfhVCdHXwORYQ8oT2I',
    'EvsQcqzTCi6lt6zGMn9A',
    'eVtwuJndDDz8Mru0QOBW',
    'nI53VyGowRNiy35IpP3v',
    'opFqEgAQUxULOwZbBBRK',
    'wnKj8Zz9vnTlVrU5OvYI',
  };

  List<PaymentEntry> get entries =>
      _entriesBox.values.toList()..sort((a, b) => b.date.compareTo(a.date));

  List<AppContact> get clubMembers => _globalContacts.contacts
      .where((c) => _clubMemberIds.contains(c.id))
      .toList();

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

}
