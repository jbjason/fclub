import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/feature/settings/presentation/widget/settings_header.dart';
import 'package:fclub/feature/settings/presentation/widget/settings_profile_card.dart';
import 'package:fclub/feature/settings/presentation/widget/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

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

  testWidgets('Settings components render and respond in light theme', (
    tester,
  ) async {
    var tileTapped = false;
    var profileTapped = false;

    await _pumpSettingsPreview(
      tester,
      brightness: Brightness.light,
      locale: const Locale('en'),
      profileOnTap: () => profileTapped = true,
      tileOnTap: () => tileTapped = true,
    );

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Fundora Member'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Fundora Member'));
    await tester.tap(find.text('Appearance'));

    expect(profileTapped, isTrue);
    expect(tileTapped, isTrue);
  });

  testWidgets('Settings components render localized copy in dark theme', (
    tester,
  ) async {
    await _pumpSettingsPreview(
      tester,
      brightness: Brightness.dark,
      locale: const Locale('bn'),
      profileOnTap: () {},
      tileOnTap: () {},
    );

    expect(find.text('সেটিংস'), findsOneWidget);
    expect(find.text('ফান্ডোরা সদস্য'), findsOneWidget);
    expect(find.text('চেহারা'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpSettingsPreview(
  WidgetTester tester, {
  required Brightness brightness,
  required Locale locale,
  required VoidCallback profileOnTap,
  required VoidCallback tileOnTap,
}) async {
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('bn')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: locale,
      saveLocale: false,
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: ThemeData(
            useMaterial3: true,
            brightness: brightness,
            colorScheme: ColorScheme.fromSeed(
              seedColor: MyColor.primary,
              brightness: brightness,
            ),
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SettingsHeader(),
                    const SizedBox(height: 16),
                    SettingsProfileCard(
                      displayName: context.tr('settings_default_user_name'),
                      email: 'member@fundora.app',
                      photoUrl: '',
                      emailVerified: true,
                      onTap: profileOnTap,
                    ),
                    const SizedBox(height: 16),
                    SettingsTile(
                      icon: Icons.palette_outlined,
                      accent: MyColor.primary,
                      title: context.tr('appearance'),
                      subtitle: context.tr('system_default'),
                      onTap: tileOnTap,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}
