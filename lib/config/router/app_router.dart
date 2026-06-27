import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/feature/auth/data/model/auth_user.dart';
import 'package:fclub/feature/auth/data/repository/auth_repository.dart';
import 'package:fclub/feature/auth/presentation/provider/signin_provider.dart';
import 'package:fclub/feature/auth/presentation/screens/auth_screen.dart';
import 'package:fclub/feature/home/presentation/screens/home.dart';
import 'package:fclub/feature/kurbani/presentation/screens/kurbani_screen.dart';
import 'package:fclub/feature/pack_check/presentation/screens/pack_check_screen.dart';
import 'package:fclub/feature/tour/presentation/screens/tour_cost_manage_screen.dart';
import 'package:fclub/feature/tour/presentation/screens/tour_history_screen.dart';
import 'package:fclub/feature/tour/presentation/screens/tour_summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppRouteName {
  static const String authGate = '/';
  static const String signIn = '/auth/sign-in';
  static const String settings = '/settings';
  static const String profileDetails = '/settings/profile-details';
  static const String home = '/home';
  static const String kurbani = '/home/kurbani';
  static const String tourCostManage = '/home/tour-cost-manage';
  static const String tourManage = '/home/tour-cost-manage/session';
  static const String tourSummary = '/home/tour-cost-manage/summary';
  static const String packCheck = '/home/carry-check';
}

abstract class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRouteName.signIn:
        return _materialRoute(
          settings: settings,
          child: ChangeNotifierProvider(
            create: (context) => SignInProvider(context.read<AuthRepository>()),
            child: const AuthScreen(),
          ),
        );
      case AppRouteName.tourCostManage:
        return _materialRoute(
          settings: settings,
          child: const TourHistoryScreen(),
        );
      case AppRouteName.tourManage:
        return _materialRoute(
          settings: settings,
          child: const TourCostManageScreen(),
        );
      case AppRouteName.tourSummary:
        return _materialRoute(
          settings: settings,
          child: const TourSummaryScreen(),
        );

      case AppRouteName.kurbani:
        return _materialRoute(settings: settings, child: const KurbaniScreen());
      case AppRouteName.packCheck:
        return _materialRoute(settings: settings, child: const PackCheckScreen());
      //     case AppRouteName.settings:
      //       return _materialRoute(settings: settings, child: SettingsScreen());
      //     case AppRouteName.profileDetails:
      //       final arguments = settings.arguments;
      //       final detailsArguments = arguments is ProfileDetailsRouteArguments
      //           ? arguments
      //           : null;

      //       return _materialRoute(
      //         settings: settings,
      //         child: detailsArguments == null
      //             ? const _RouteMessageScreen(message: 'Profile details not found.')
      //             : ChangeNotifierProvider(
      //                 create: (context) => ProfileDetailsProvider(
      //                   context.read<ProfileRepository>(),
      //                   initialProfile: detailsArguments.toInitialProfile(),
      //                 ),
      //                 child: ProfileDetailsScreen(arguments: detailsArguments),
      //               ),
      //       );
      case AppRouteName.home:
        return _materialRoute(settings: settings, child: const Home());
      //     case AppRouteName.leads:
      //       return _materialRoute(
      //         settings: settings,
      //         child: ChangeNotifierProvider(
      //           create: (context) => LeadsProvider(context.read<LeadsRepository>()),
      //           child: const LeadsScreen(),
      //         ),
      //       );

      case AppRouteName.authGate:
      default:
        return _materialRoute(settings: settings, child: const _AuthGate());
    }
  }

  static MaterialPageRoute<dynamic> _materialRoute({
    required RouteSettings settings,
    required Widget child,
  }) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (_) => child,
    );
  }
}

class _RouteMessageScreen extends StatelessWidget {
  const _RouteMessageScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(message)));
  }
}

/// Decides whether the user lands on [AuthScreen] or [Home].
///
/// Subscribes to [AuthRepository.authStateChanges] once and keeps reacting to
/// it for the lifetime of the app, so both the initial auto-sign-in check and
/// any later sign-in/sign-out transition are driven by the same stream.
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late final Stream<AuthUser?> _authStateChanges = context
      .read<AuthRepository>()
      .authStateChanges();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthUser?>(
      stream: _authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AuthGateLoading();
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

class _AuthGateLoading extends StatelessWidget {
  const _AuthGateLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: MyColor.logBackColor,
      body: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
