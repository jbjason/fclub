import 'dart:async';

import 'package:fclub/feature/auth/data/model/auth_action_result.dart';
import 'package:fclub/feature/auth/data/model/auth_user.dart';
import 'package:fclub/feature/auth/data/repository/auth_repository.dart';
import 'package:flutter/foundation.dart';

/// Exposes the signed-in user reactively (for screens outside the sign-in
/// flow, e.g. Settings) and drives the sign-out action.
class AuthSessionProvider with ChangeNotifier {
  AuthSessionProvider(this._authRepository) {
    _subscription = _authRepository.authStateChanges().listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<AuthUser?> _subscription;

  AuthUser? _currentUser;
  bool _isSigningOut = false;

  AuthUser? get currentUser => _currentUser;
  bool get isSigningOut => _isSigningOut;

  Future<AuthActionResult> signOut() async {
    _isSigningOut = true;
    notifyListeners();

    try {
      await _authRepository.signOut();
      return AuthActionResult.success('Signed out successfully.');
    } catch (error) {
      final message = error.toString().replaceFirst('Exception: ', '');
      return AuthActionResult.failure(message);
    } finally {
      _isSigningOut = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
