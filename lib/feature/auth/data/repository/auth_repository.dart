import 'package:firebase_auth/firebase_auth.dart';
import 'package:fclub/core/services/auth/firebase_auth_service.dart';
import 'package:fclub/core/services/global_service.dart';
import 'package:fclub/feature/auth/data/model/auth_user.dart';

class AuthRepository {
  AuthRepository({
    required FirebaseAuthService firebaseAuthService,
    required GlobalService globalService,
  }) : _firebaseAuthService = firebaseAuthService,
       _globalService = globalService;

  final FirebaseAuthService _firebaseAuthService;
  final GlobalService _globalService;

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

  Future<void> signOut() async {
    await _firebaseAuthService.signOut();
    await _globalService.clearSession();
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
