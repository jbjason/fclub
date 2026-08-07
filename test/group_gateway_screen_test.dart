import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/config/theme/app_theme.dart';
import 'package:fclub/core/services/locale_service.dart';
import 'package:fclub/feature/home/presentation/screens/group_gateway_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const preferencesChannel = MethodChannel(
    'plugins.flutter.io/shared_preferences',
  );

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(preferencesChannel, (call) async {
          if (call.method == 'getAll') return <String, Object>{};
          return true;
        });
    await EasyLocalization.ensureInitialized();
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(preferencesChannel, null);
  });

  testWidgets('renders and exposes both group paths in the light theme', (
    tester,
  ) async {
    var joinTaps = 0;
    var createTaps = 0;
    var signOutTaps = 0;

    await _pumpGateway(
      tester,
      locale: const Locale('en'),
      themeMode: ThemeMode.light,
      onJoin: () => joinTaps++,
      onCreate: () => createTaps++,
      onSignOut: () => signOutTaps++,
    );

    expect(find.text('Find your circle'), findsOneWidget);
    expect(find.text('Enter a group'), findsOneWidget);
    expect(find.text('Create your own group'), findsOneWidget);
    expect(find.byIcon(Icons.logout_rounded), findsOneWidget);

    await tester.tap(find.byKey(const Key('group-gateway-logout-button')));
    await tester.pump();

    await tester.enterText(
      find.byKey(const Key('group-secret-code-field')),
      'AURORA-27',
    );
    expect(find.text('AURORA-27'), findsOneWidget);

    await tester.ensureVisible(find.text('Unlock group'));
    await tester.tap(find.text('Unlock group'));
    await tester.pump();

    await tester.ensureVisible(find.text('Create a group'));
    await tester.tap(find.text('Create a group'));
    await tester.pump();

    expect(joinTaps, 1);
    expect(createTaps, 1);
    expect(signOutTaps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders Bangla copy without overflow in the dark theme', (
    tester,
  ) async {
    await _pumpGateway(
      tester,
      locale: const Locale('bn'),
      themeMode: ThemeMode.dark,
      onJoin: () {},
      onCreate: () {},
      onSignOut: () {},
    );

    expect(find.text('আপনার আপনজনদের খুঁজে নিন'), findsOneWidget);
    expect(find.text('একটি গ্রুপে প্রবেশ করুন'), findsOneWidget);
    expect(find.text('নিজের গ্রুপ তৈরি করুন'), findsOneWidget);

    await tester.ensureVisible(find.text('গ্রুপ তৈরি করুন'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpGateway(
  WidgetTester tester, {
  required Locale locale,
  required ThemeMode themeMode,
  required VoidCallback onJoin,
  required VoidCallback onCreate,
  required VoidCallback onSignOut,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('bn')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: locale,
      saveLocale: false,
      child: ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: AppTheme.light(context),
            darkTheme: AppTheme.dark(context),
            themeMode: themeMode,
            home: GroupGatewayScreen(
              onJoinGroup: onJoin,
              onCreateGroup: onCreate,
              onSignOut: onSignOut,
            ),
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}
