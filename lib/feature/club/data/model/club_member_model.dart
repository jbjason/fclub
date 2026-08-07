import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fclub/feature/club/data/model/club_member.dart';

abstract final class ClubMemberModel {
  static ClubMember fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    return ClubMember(
      id: document.id,
      name: _first(data, const ['username', 'name', 'displayName'], 'Member'),
      email: _first(data, const ['email'], ''),
      profilePic: _first(data, const [
        'profilePic',
        'photoUrl',
        'photoURL',
      ], ''),
    );
  }

  static ClubMemberCandidate candidateFromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    return ClubMemberCandidate(
      id: document.id,
      name: _first(data, const ['username', 'name', 'displayName'], 'Member'),
      email: _first(data, const ['email'], ''),
      profilePic: _first(data, const [
        'profilePic',
        'photoUrl',
        'photoURL',
      ], ''),
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
}
