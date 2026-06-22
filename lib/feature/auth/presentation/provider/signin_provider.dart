// ignore_for_file: use_build_context_synchronously

import 'package:fclub/core/util/my_dialog.dart';
import 'package:fclub/feature/auth/data/model/auth_action_result.dart';
import 'package:fclub/feature/auth/data/model/auth_user.dart';
import 'package:fclub/feature/auth/data/repository/auth_repository.dart';
import 'package:flutter/material.dart';

class SignInProvider with ChangeNotifier {
  SignInProvider(this._authRepository);
  final AuthRepository _authRepository;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  AuthUser? _currentUser;
  bool _isSigningOut = false;
  String? _errorMessage;
  bool _isLoading = false;

  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isSigningOut => _isSigningOut;
  String? get errorMessage => _errorMessage;

  Future<void> signIn(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.signInWithEmail(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );
      MyDialog().showSuccessToast(
        msg: 'Logged in successfully!',
        context: context,
      );
    } catch (error) {
      _errorMessage = _toMessage(error);
      MyDialog().showFailedToast(msg: _errorMessage!, context: context);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AuthActionResult> signOut() async {
    _isSigningOut = true;
    notifyListeners();

    try {
      await _authRepository.signOut();
      _errorMessage = null;
      return AuthActionResult.success('Signed out successfully.');
    } catch (error) {
      final message = _toMessage(error);
      _errorMessage = message;
      return AuthActionResult.failure(message);
    } finally {
      _isSigningOut = false;
      notifyListeners();
    }
  }

  String? validateEmail(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) {
      return 'Email is required.';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required.';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  String _toMessage(Object error) {
    final message = error.toString();
    return message.startsWith('Exception: ')
        ? message.replaceFirst('Exception: ', '')
        : message;
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }
}
