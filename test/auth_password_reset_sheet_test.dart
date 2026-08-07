import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/feature/auth/data/model/auth_action_result.dart';
import 'package:fclub/feature/auth/presentation/widgets/auth_password_reset_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const preferencesChannel = MethodChannel(
    'plugins.flutter.io/shared_preferences',
  );

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
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

  testWidgets('validates email and submits a password reset request', (
    tester,
  ) async {
    String? submittedEmail;
    var submitCount = 0;
    await _pumpResetSheet(
      tester,
      initialEmail: '',
      onSubmit: (email) async {
        submitCount++;
        submittedEmail = email;
        return AuthActionResult.success();
      },
    );

    expect(find.text('Reset your password'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('send-password-reset-link')));
    await tester.pump();

    expect(find.text('Email is required.'), findsOneWidget);
    expect(submitCount, 0);

    await tester.enterText(find.byType(TextFormField), 'member@example.com');
    await tester.tap(find.byKey(const ValueKey('send-password-reset-link')));
    await tester.pumpAndSettle();

    expect(submittedEmail, 'member@example.com');
    expect(submitCount, 1);
    expect(find.text('Reset your password'), findsNothing);
  });
}

Future<void> _pumpResetSheet(
  WidgetTester tester, {
  required String initialEmail,
  required PasswordResetCallback onSubmit,
}) async {
  await tester.pumpWidget(
    EasyLocalization(
      key: UniqueKey(),
      supportedLocales: const [Locale('en'), Locale('bn')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      saveLocale: false,
      child: Builder(
        builder: (context) => MaterialApp(
          key: UniqueKey(),
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => showModalBottomSheet<AuthActionResult>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => AuthPasswordResetSheet(
                      initialEmail: initialEmail,
                      onSubmit: onSubmit,
                    ),
                  ),
                  child: const Text('Open reset'),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Open reset'));
  await tester.pumpAndSettle();
}
