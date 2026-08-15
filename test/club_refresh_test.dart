import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/feature/club/data/model/club_month_summary.dart';
import 'package:fclub/feature/club/presentation/widgets/club_widgets/club_overview_tab.dart';
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

  testWidgets('ClubScreen overview pull-to-refresh completes', (tester) async {
    var refreshCount = 0;
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('bn')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        saveLocale: false,
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) => MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: Scaffold(
              body: ClubOverviewTab(
                summaries: [
                  ClubMonthSummary(
                    month: _month,
                    memberCount: 2,
                    target: 10000,
                    collected: 5000,
                    pending: 0,
                    rejected: 0,
                  ),
                ],
                onRefresh: () async {
                  refreshCount++;
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).last, const Offset(0, 320));
    await tester.pumpAndSettle();

    expect(refreshCount, 1);
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });
}

final _month = DateTime(2026, 8);
