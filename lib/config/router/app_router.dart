import 'package:fclub/feature/auth/data/repository/auth_repository.dart';
import 'package:fclub/core/services/auth/firebase_auth_service.dart';
import 'package:fclub/feature/auth/presentation/provider/signin_provider.dart';
import 'package:fclub/feature/auth/presentation/screens/auth_gate_screen.dart';
import 'package:fclub/feature/auth/presentation/screens/auth_screen.dart';
import 'package:fclub/feature/club/presentation/screens/club_monthly_overview_screen.dart';
import 'package:fclub/feature/home/presentation/screens/group_gateway_screen.dart';
import 'package:fclub/feature/home/data/models/group_user.dart';
import 'package:fclub/feature/home/data/repositories/group_repository.dart';
import 'package:fclub/feature/home/presentation/provider/group_creation_provider.dart';
import 'package:fclub/feature/home/presentation/screens/group_create_screen.dart';
import 'package:fclub/feature/home/presentation/screens/home.dart';
import 'package:fclub/feature/kurbani/presentation/screens/kurbani_screen.dart';
import 'package:fclub/feature/locker/presentation/screens/locker_screen.dart';
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
  static const String groupGateway = '/groups';
  static const String groupCreate = '/groups/create';
  static const String home = '/home';
  static const String club = '/home/club';
  static const String locker = '/home/locker';
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

      case AppRouteName.club:
        return _materialRoute(
          settings: settings,
          child: const ClubMonthlyOverviewScreen(),
        );
      case AppRouteName.locker:
        return _materialRoute(settings: settings, child: const LockerScreen());
      case AppRouteName.kurbani:
        return _materialRoute(settings: settings, child: const KurbaniScreen());
      case AppRouteName.packCheck:
        return _materialRoute(
          settings: settings,
          child: const PackCheckScreen(),
        );
      case AppRouteName.groupGateway:
        return _materialRoute(
          settings: settings,
          child: const GroupGatewayScreen(),
        );
      case AppRouteName.groupCreate:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (context) {
            final firebaseUser = context
                .read<FirebaseAuthService>()
                .currentUser;
            final fallbackName = firebaseUser?.email?.split('@').first;
            return ChangeNotifierProvider(
              create: (context) => GroupCreationProvider(
                repository: context.read<GroupRepository>(),
                signedInUser: GroupUser(
                  id: firebaseUser?.uid ?? '',
                  username: firebaseUser?.displayName?.trim().isNotEmpty == true
                      ? firebaseUser!.displayName!.trim()
                      : fallbackName?.trim().isNotEmpty == true
                      ? fallbackName!.trim()
                      : 'Fundora Member',
                  profilePic: firebaseUser?.photoURL ?? '',
                  email: firebaseUser?.email ?? '',
                ),
              )..loadUsers(),
              child: const GroupCreateScreen(),
            );
          },
        );
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
        return _materialRoute(
          settings: settings,
          child: const AuthGateScreen(),
        );
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
