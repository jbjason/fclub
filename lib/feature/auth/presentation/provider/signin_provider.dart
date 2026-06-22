// ignore_for_file: use_build_context_synchronously

import 'package:fclub/core/util/my_dialog.dart';
import 'package:fclub/feature/auth/data/model/auth_action_result.dart';
import 'package:fclub/feature/auth/data/model/auth_user.dart';
import 'package:fclub/feature/auth/data/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignInProvider with ChangeNotifier {
  SignInProvider(this._authRepository);
  final AuthRepository _authRepository;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  AuthUser? _currentUser;
  bool _isSigningOut = false;
  final bool _isDeletingAccount = false;
  String? _errorMessage;
  bool _isLoading = false;

  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isSigningOut => _isSigningOut;
  bool get isDeletingAccount => _isDeletingAccount;
  String? get errorMessage => _errorMessage;

  void checkAuthState() {
    final auth = FirebaseAuth.instance;
    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
  }

  Future<void> signIn(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    final auth = FirebaseAuth.instance;
    try {
      _isLoading = true;
      notifyListeners();
      await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );
      _isLoading = false;
      notifyListeners();
      MyDialog().showSuccessToast(
        msg: 'Logged in successfully!',
        context: context,
      );
    } on FirebaseAuthException catch (err) {
      _isLoading = false;
      notifyListeners();
      String message = 'An error occurred, please check your credentials!';
      if (err.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (err.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      }
      MyDialog().showFailedToast(msg: message, context: context);
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
    if (password.length < 4) {
      return 'Password must be at least 8 characters.';
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
