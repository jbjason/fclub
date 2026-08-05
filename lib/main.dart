import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/config/firebase/firebase_initializer.dart';
import 'package:fclub/config/router/app_router.dart';
import 'package:fclub/config/theme/app_theme.dart';
import 'package:fclub/core/navigation/app_navigator.dart';
import 'package:fclub/core/services/auth/firebase_auth_service.dart';
import 'package:fclub/core/services/global_service.dart';
import 'package:fclub/core/services/locale_service.dart';
import 'package:fclub/feature/auth/data/repository/auth_repository.dart';
import 'package:fclub/feature/auth/presentation/provider/auth_session_provider.dart';
import 'package:fclub/core/services/contacts/global_contacts_hive_box.dart';
import 'package:fclub/core/services/contacts/global_contacts_provider.dart';
import 'package:fclub/feature/club/data/repositories/firestore_club_repository.dart';
import 'package:fclub/feature/club/data/repositories/club_repository.dart';
import 'package:fclub/feature/club/presentation/provider/club_provider.dart';
import 'package:fclub/feature/home/data/repositories/firestore_group_repository.dart';
import 'package:fclub/feature/home/data/repositories/group_repository.dart';
import 'package:fclub/feature/home/presentation/provider/group_session_provider.dart';
import 'package:fclub/feature/kurbani/data/kurbani_hive_boxes.dart';
import 'package:fclub/feature/locker/data/locker_hive_box.dart';
import 'package:fclub/feature/locker/presentation/provider/locker_provider.dart';
import 'package:fclub/feature/pack_check/data/pack_check_hive_boxes.dart';
import 'package:fclub/feature/kurbani/presentation/provider/kurbani_provider.dart';
import 'package:fclub/feature/settings/data/repository/settings_repository.dart';
import 'package:fclub/feature/settings/data/settings_hive_box.dart';
import 'package:fclub/feature/settings/presentation/provider/settings_provider.dart';
import 'package:fclub/feature/tour/data/hive_boxes.dart';
import 'package:fclub/feature/tour/presentation/provider/tour_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.initialize();
  await GlobalService.instance.initialize();
  await GlobalContactsHiveBox.openBox();
  await TourHiveBoxes.openBoxes();
  await KurbaniHiveBoxes.openBoxes();
  await PackCheckHiveBoxes.openBoxes();
  await LockerHiveBox.openBoxes();
  await SettingsHiveBox.openBox();
  await EasyLocalization.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('bn')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          Provider<FirebaseAuthService>(create: (_) => FirebaseAuthService()),
          Provider<AuthRepository>(
            create: (context) => AuthRepository(
              firebaseAuthService: context.read<FirebaseAuthService>(),
              globalService: GlobalService.instance,
            ),
          ),
          Provider<GroupRepository>(create: (_) => FirestoreGroupRepository()),
          Provider<ClubRepository>(create: (_) => FirestoreClubRepository()),
          ChangeNotifierProvider(create: (_) => GroupSessionProvider()),
          ChangeNotifierProvider(
            create: (context) =>
                AuthSessionProvider(context.read<AuthRepository>()),
          ),
          ChangeNotifierProvider(create: (_) => GlobalContactsProvider()),
          ChangeNotifierProvider(
            create: (context) =>
                TourProvider(context.read<GlobalContactsProvider>()),
          ),
          ChangeNotifierProvider(
            create: (context) =>
                KurbaniProvider(context.read<GlobalContactsProvider>()),
          ),
          ChangeNotifierProvider(
            create: (context) => ClubProvider(
              repository: context.read<ClubRepository>(),
              groupSession: context.read<GroupSessionProvider>(),
              authService: context.read<FirebaseAuthService>(),
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => LockerProvider(context.read<ClubProvider>()),
          ),
          Provider<SettingsRepository>(create: (_) => SettingsRepository()),
          ChangeNotifierProvider(
            create: (context) =>
                SettingsProvider(context.read<SettingsRepository>()),
          ),
        ],
        child: Consumer2<LocaleProvider, SettingsProvider>(
          builder: (context, localeProvider, settingsViewModel, _) =>
              ScreenUtilInit(
                designSize: const Size(375, 812),
                minTextAdapt: true,
                builder: (context, child) => MaterialApp(
                  navigatorKey: appNavigatorKey,
                  title: 'F Club',
                  debugShowCheckedModeBanner: false,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale, // This will update now
                  theme: AppTheme.light(context),
                  darkTheme: AppTheme.dark(context),
                  themeMode: settingsViewModel.settings.themeMode,
                  initialRoute: AppRouteName.authGate,
                  onGenerateRoute: AppRouter.onGenerateRoute,
                ),
              ),
        ),
      ),
    );
  }
}
