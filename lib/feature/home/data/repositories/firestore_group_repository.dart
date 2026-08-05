import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fclub/feature/club/data/model/club_constants.dart';
import 'package:fclub/feature/home/data/models/create_group_request.dart';
import 'package:fclub/feature/home/data/models/created_group.dart';
import 'package:fclub/feature/home/data/models/group_failure.dart';
import 'package:fclub/feature/home/data/models/group_user.dart';
import 'package:fclub/feature/home/data/models/joined_group.dart';
import 'package:fclub/feature/home/data/repositories/group_repository.dart';

class FirestoreGroupRepository implements GroupRepository {
  FirestoreGroupRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const _groupsCollection = 'groups';
  static const _usersCollection = 'users';
  static const _maxAdditionalMembers = 498;

  final FirebaseFirestore _firestore;

  @override
  Future<List<GroupUser>> getUsers() async {
    try {
      final snapshot = await _firestore.collection(_usersCollection).get();
      final users =
          snapshot.docs.map(GroupUser.fromFirestore).toList(growable: false)
            ..sort(
              (first, second) => first.username.toLowerCase().compareTo(
                second.username.toLowerCase(),
              ),
            );
      return users;
    } on FirebaseException catch (error) {
      throw _mapFirebaseFailure(error, loadingUsers: true);
    } catch (error) {
      throw GroupFailure(GroupFailureCode.usersLoadFailed, error);
    }
  }

  @override
  Future<CreatedGroup> createGroup(CreateGroupRequest request) async {
    final groupName = request.name.trim();
    final pinCode = request.pinCode.trim().toUpperCase();
    final compactPin = pinCode.replaceAll(RegExp('[^A-Z0-9]'), '');

    if (groupName.length < 3 ||
        groupName.length > 50 ||
        compactPin.length < 6 ||
        pinCode.length > 12 ||
        request.members.any((member) => member.id.trim().isEmpty)) {
      throw const GroupFailure(GroupFailureCode.invalidInput);
    }
    if (request.creator.id.trim().isEmpty) {
      throw const GroupFailure(GroupFailureCode.unauthenticated);
    }
    if (request.members.length > _maxAdditionalMembers) {
      throw const GroupFailure(GroupFailureCode.tooManyMembers);
    }

    final groups = _firestore.collection(_groupsCollection);

    try {
      final matchingPin = await groups
          .where('pinCode', isEqualTo: pinCode)
          .limit(1)
          .get();
      if (matchingPin.docs.isNotEmpty) {
        throw const GroupFailure(GroupFailureCode.pinUnavailable);
      }

      final groupDocument = groups.doc();
      final batch = _firestore.batch();
      batch.set(groupDocument, {
        'name': groupName,
        'pinCode': pinCode,
        'createdBy': request.creator.id,
        'createdAt': FieldValue.serverTimestamp(),
        'id': groupDocument.id,
      });
      batch.set(groupDocument.collection('projects').doc('club'), {
        'id': 'club',
        'name': 'Fundora Club',
        'monthlyTargetPerMember': ClubConstants.monthlyTargetPerMember,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final membersById = <String, GroupUser>{
        for (final member in request.members) member.id: member,
        request.creator.id: request.creator,
      };

      for (final entry in membersById.entries) {
        final member = entry.value;
        batch.set(groupDocument.collection('members').doc(entry.key), {
          'role': entry.key == request.creator.id ? 'admin' : 'member',
          'joinedAt': FieldValue.serverTimestamp(),
          'username': member.username,
          'profilePic': member.profilePic,
          'email': member.email.trim().toLowerCase(),
          'id': entry.key,
        });
      }

      await batch.commit();

      return CreatedGroup(
        id: groupDocument.id,
        name: groupName,
        pinCode: pinCode,
        memberCount: membersById.length,
      );
    } on GroupFailure {
      rethrow;
    } on FirebaseException catch (error) {
      throw _mapFirebaseFailure(error);
    } catch (error) {
      throw GroupFailure(GroupFailureCode.unknown, error);
    }
  }

  @override
  Future<JoinedGroup> joinGroup({
    required String pinCode,
    required GroupUser user,
  }) async {
    final normalizedPin = pinCode.trim().toUpperCase();
    final compactPin = normalizedPin.replaceAll(RegExp('[^A-Z0-9]'), '');
    final normalizedEmail = user.email.trim().toLowerCase();

    if (compactPin.length < 6 || normalizedPin.length > 12) {
      throw const GroupFailure(GroupFailureCode.invalidInput);
    }
    if (user.id.trim().isEmpty) {
      throw const GroupFailure(GroupFailureCode.unauthenticated);
    }
    if (normalizedEmail.isEmpty) {
      throw const GroupFailure(GroupFailureCode.emailUnavailable);
    }

    try {
      final groupSnapshot = await _firestore
          .collection(_groupsCollection)
          .where('pinCode', isEqualTo: normalizedPin)
          .limit(1)
          .get();
      if (groupSnapshot.docs.isEmpty) {
        throw const GroupFailure(GroupFailureCode.groupNotFound);
      }

      final groupDocument = groupSnapshot.docs.first;
      final groupData = groupDocument.data();
      final members = groupDocument.reference.collection('members');
      final existingMembers = await members.get();
      final alreadyMember = existingMembers.docs.any((document) {
        final email = document.data()['email'];
        return document.id == user.id ||
            (email is String && email.trim().toLowerCase() == normalizedEmail);
      });

      if (!alreadyMember) {
        final member = await _resolveUserProfile(
          fallback: user,
          normalizedEmail: normalizedEmail,
        );
        await members.doc(user.id).set({
          'role': 'member',
          'joinedAt': FieldValue.serverTimestamp(),
          'username': member.username,
          'profilePic': member.profilePic,
          'email': normalizedEmail,
          'id': user.id,
        });
      }

      return JoinedGroup(
        id: groupDocument.id,
        name: _stringValue(groupData['name'], fallback: 'Fundora Group'),
        pinCode: normalizedPin,
        alreadyMember: alreadyMember,
      );
    } on GroupFailure {
      rethrow;
    } on FirebaseException catch (error) {
      throw _mapFirebaseFailure(error);
    } catch (error) {
      throw GroupFailure(GroupFailureCode.unknown, error);
    }
  }

  Future<GroupUser> _resolveUserProfile({
    required GroupUser fallback,
    required String normalizedEmail,
  }) async {
    final snapshot = await _firestore
        .collection(_usersCollection)
        .where('email', isEqualTo: normalizedEmail)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) {
      return fallback.copyWith(email: normalizedEmail);
    }
    return GroupUser.fromFirestore(
      snapshot.docs.first,
    ).copyWith(id: fallback.id, email: normalizedEmail);
  }

  String _stringValue(Object? value, {required String fallback}) {
    return value is String && value.trim().isNotEmpty ? value.trim() : fallback;
  }

  GroupFailure _mapFirebaseFailure(
    FirebaseException error, {
    bool loadingUsers = false,
  }) {
    return switch (error.code) {
      'permission-denied' => GroupFailure(
        GroupFailureCode.permissionDenied,
        error,
      ),
      'unavailable' ||
      'deadline-exceeded' => GroupFailure(GroupFailureCode.network, error),
      _ => GroupFailure(
        loadingUsers
            ? GroupFailureCode.usersLoadFailed
            : GroupFailureCode.unknown,
        error,
      ),
    };
  }
}
