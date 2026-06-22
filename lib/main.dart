import 'package:fclub/config/firebase/firebase_initializer.dart';
import 'package:fclub/config/router/app_router.dart';
import 'package:fclub/config/theme/app_theme.dart';
import 'package:fclub/core/navigation/app_navigator.dart';
import 'package:fclub/core/services/global_service.dart';
import 'package:fclub/feature/auth/data/repository/auth_repository.dart';
import 'package:fclub/feature/auth/presentation/provider/signin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.initialize();
  await GlobalService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SignInProvider(context.read<AuthRepository>()),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, child) => MaterialApp(
          navigatorKey: appNavigatorKey,
          title: 'Op Media',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(context),
          initialRoute: //AppRouteName.dashboard,
              AppRouteName.authGate,
          // onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
  }
}
