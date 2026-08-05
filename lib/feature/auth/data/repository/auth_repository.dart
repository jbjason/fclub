import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fclub/core/services/auth/firebase_auth_service.dart';
import 'package:fclub/core/services/global_service.dart';
import 'package:fclub/feature/auth/data/model/auth_user.dart';
import 'package:fclub/feature/auth/data/model/firebase_user_profile.dart';

class AuthRepository {
  AuthRepository({
    required FirebaseAuthService firebaseAuthService,
    required GlobalService globalService,
    FirebaseFirestore? firestore,
  }) : _firebaseAuthService = firebaseAuthService,
       _globalService = globalService,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuthService _firebaseAuthService;
  final GlobalService _globalService;
  final FirebaseFirestore _firestore;

  Stream<AuthUser?> authStateChanges() {
    return _firebaseAuthService.idTokenChanges().asyncMap((user) async {
      if (user == null) {
        await _globalService.clearSession();
        return null;
      }

      final authUser = AuthUser.fromFirebaseUser(user);
      final idToken = await user.getIdToken();
      await _globalService.setSession(user: authUser, idToken: idToken);

      return authUser;
    });
  }

  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuthService.signInWithEmail(
        email: email,
        password: password,
      );
      return AuthUser.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (exception) {
      throw Exception(_mapFirebaseAuthException(exception));
    }
  }

  Future<AuthUser> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    User? createdUser;

    try {
      final normalizedEmail = email.trim().toLowerCase();
      final normalizedName = name.trim();
      final credential = await _firebaseAuthService.createUserWithEmail(
        email: normalizedEmail,
        password: password,
      );
      createdUser = credential.user;

      if (createdUser == null) {
        throw Exception('Firebase did not return the created user.');
      }

      await createdUser.updateDisplayName(normalizedName);

      final profile = FirebaseUserProfile(
        id: createdUser.uid,
        email: normalizedEmail,
        name: normalizedName,
      );
      await _firestore
          .collection('users')
          .doc(createdUser.uid)
          .set(profile.toFirestore());

      return AuthUser.fromFirebaseUser(createdUser);
    } on FirebaseAuthException catch (exception) {
      await _deleteCreatedUser(createdUser);
      throw Exception(_mapFirebaseAuthException(exception));
    } on FirebaseException catch (exception) {
      await _deleteCreatedUser(createdUser);
      throw Exception(
        exception.message ?? 'Could not create the user profile.',
      );
    } catch (error) {
      await _deleteCreatedUser(createdUser);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuthService.signOut();
    await _globalService.clearSession();
  }

  Future<void> _deleteCreatedUser(User? user) async {
    if (user == null) return;

    try {
      await user.delete();
    } catch (_) {
      // Preserve the original signup error if Firebase cannot roll back.
    }
  }

  String _mapFirebaseAuthException(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in Firebase.';
      default:
        return exception.message ?? 'Authentication failed. Please try again.';
    }
  }
}
