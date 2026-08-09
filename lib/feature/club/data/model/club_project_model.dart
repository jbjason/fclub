import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fclub/feature/club/data/model/club_project.dart';

abstract final class ClubProjectModel {
  static ClubProject? fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    if (!document.exists || data == null) return null;
    return ClubProject(
      id: document.id,
      name: _text(data['name'], fallback: 'Club'),
      adminId: _text(data['adminId']),
      monthlyTargetPerMember:
          (data['monthlyTargetPerMember'] as num?)?.toDouble() ?? 0,
    );
  }

  static String _text(Object? value, {String fallback = ''}) {
    return value is String && value.trim().isNotEmpty ? value.trim() : fallback;
  }
}
