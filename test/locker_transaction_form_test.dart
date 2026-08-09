import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/feature/locker/data/models/locker_participant.dart';
import 'package:fclub/feature/locker/data/models/locker_transaction.dart';
import 'package:fclub/feature/locker/presentation/widgets/add_transaction/locker_transaction_form.dart';
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

  testWidgets('expense is first and selected by default', (tester) async {
    LockerTransactionType? submittedType;
    await _pumpForm(
      tester,
      locale: const Locale('en'),
      onSubmit:
          ({
            required type,
            required amount,
            required participantId,
            note,
          }) async {
            submittedType = type;
          },
    );

    final expense = find.byKey(const Key('locker-expense-option'));
    final contribution = find.byKey(const Key('locker-contribution-option'));
    expect(
      tester.getTopLeft(expense).dx,
      lessThan(tester.getTopLeft(contribution).dx),
    );

    await tester.enterText(
      find.byKey(const Key('locker-transaction-amount')),
      '850',
    );
    tester.testTextInput.hide();
    await tester.pump();
    final submit = find.byKey(const Key('locker-transaction-submit'));
    await tester.scrollUntilVisible(
      submit,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(submit);
    await tester.pump();

    expect(submittedType, LockerTransactionType.expense);
  });

  testWidgets('transaction choices and details render in Bangla', (
    tester,
  ) async {
    await _pumpForm(
      tester,
      locale: const Locale('bn'),
      onSubmit:
          ({
            required type,
            required amount,
            required participantId,
            note,
          }) async {},
    );

    expect(find.text('খরচ'), findsOneWidget);
    expect(find.text('জমা'), findsOneWidget);
    expect(find.text('লেনদেনের বিস্তারিত'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpForm(
  WidgetTester tester, {
  required Locale locale,
  required LockerTransactionSubmit onSubmit,
}) async {
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  const participant = LockerParticipant(
    id: 'member-1',
    username: 'Fundora Member',
    email: 'member@fundora.app',
    profilePic: '',
  );

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
          home: Scaffold(
            body: LockerTransactionForm(
              participants: const [participant],
              currentParticipant: participant,
              isAdmin: true,
              isSubmitting: false,
              onSubmit: onSubmit,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
