import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/feature/auth/data/model/auth_user.dart';
import 'package:fclub/feature/auth/data/repository/auth_repository.dart';
import 'package:fclub/feature/auth/presentation/provider/signin_provider.dart';
import 'package:fclub/feature/auth/presentation/screens/auth_screen.dart';
import 'package:fclub/feature/home/presentation/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Decides whether the user lands on [AuthScreen] or [Home].
///
/// Subscribes to [AuthRepository.authStateChanges] once and keeps reacting to
/// it for the lifetime of the app, so both the initial auto-sign-in check and
/// any later sign-in/sign-out transition are driven by the same stream.
class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => AuthGateScreenState();
}

class AuthGateScreenState extends State<AuthGateScreen> {
  late final Stream<AuthUser?> _authStateChanges = context
      .read<AuthRepository>()
      .authStateChanges();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthUser?>(
      stream: _authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: MyColor.logBackColor,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }
        return snapshot.data != null
            ? const Home()
            : ChangeNotifierProvider(
                create: (context) =>
                    SignInProvider(context.read<AuthRepository>()),
                child: const AuthScreen(),
              );
      },
    );
  }
}
