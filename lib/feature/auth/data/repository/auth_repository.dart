import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:fclub/core/base/api_request_options.dart';
import 'package:fclub/core/base/base_client.dart';
import 'package:fclub/core/constants/my_api_url.dart';
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
  static final Logger _logger = Logger();

  Stream<AuthUser?> authStateChanges() {
    return _firebaseAuthService.idTokenChanges().asyncMap((user) async {
      if (user == null) {
        await _globalService.clearSession();
        return null;
      }

      final authUser = AuthUser.fromFirebaseUser(user);
      final idToken = await user.getIdToken();
      _globalService.setSession(user: authUser, idToken: idToken);

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




  Future<void> deleteAccount() async {
    final url =
        "${MyApiUrl.baseUrl}/${MyApiUrl.version}/${MyApiUrl.deleteAccount}";
    _logger.i("DELETE $url");

    final Response<dynamic> response;
    try {
      response = await BaseClient.dio.delete(
        url,
        options: ApiRequestOptions.authorized(),
      );
    } on DioException catch (exception) {
      _logger.e(
        'DELETE ${exception.requestOptions.uri}\n'
        'Error: ${exception.message}\n'
        'Status: ${exception.response?.statusCode}\n'
        'Error response: ${exception.response?.data}',
      );
      throw Exception(_mapBackendAuthException(exception));
    }

    _logger.t(
      'DELETE ${response.requestOptions.uri}\n'
      'Status: ${response.statusCode}\n'
      'Response: ${response.data}',
    );

    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      throw Exception('Unable to delete account.');
    }

    await signOut();
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
        return 'Password is too weak. Use at least 8 characters.';
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

  String _mapBackendAuthException(DioException exception) {
    final statusCode = exception.response?.statusCode;
    final responseData = exception.response?.data;
    String? backendMessage;

    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];
      final error = responseData['error'];
      if (message is String && message.trim().isNotEmpty) {
        backendMessage = message.trim();
      } else if (error is String && error.trim().isNotEmpty) {
        backendMessage = error.trim();
      }
    }

    switch (statusCode) {
      case 400:
      case 401:
      case 403:
        return backendMessage ??
            'Signed in to Firebase, but backend authorization failed. Ensure mobile app Firebase project matches the backend project.';
      case 404:
        return backendMessage ??
            'Signed in, but no backend profile exists for this account.';
      default:
        return backendMessage ??
            'Signed in to Firebase, but backend profile request failed (${statusCode ?? 'unknown'}).';
    }
  }
}
