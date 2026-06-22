import 'package:fclub/feature/auth/data/repository/auth_repository.dart';
import 'package:fclub/feature/auth/presentation/provider/signin_provider.dart';
import 'package:fclub/feature/auth/presentation/screens/auth_screen.dart';
import 'package:fclub/feature/home/presentation/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppRouteName {
  static const String authGate = '/';
  static const String signIn = '/auth/sign-in';
  static const String settings = '/settings';
  static const String profileDetails = '/settings/profile-details';
  static const String home = '/home';
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
        return _materialRoute(settings: settings, child: const Home());
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
