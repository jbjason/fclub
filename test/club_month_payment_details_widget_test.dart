import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/feature/club/data/model/club_member.dart';
import 'package:fclub/feature/club/data/model/club_month_payment_filter.dart';
import 'package:fclub/feature/club/data/model/club_month_summary.dart';
import 'package:fclub/feature/club/data/model/club_payment.dart';
import 'package:fclub/feature/club/presentation/widgets/month_payment_details/club_month_payment_filter_bar.dart';
import 'package:fclub/feature/club/presentation/widgets/month_payment_details/club_month_payment_hero.dart';
import 'package:fclub/feature/club/presentation/widgets/month_payment_details/club_month_payment_list.dart';
import 'package:fclub/feature/club/presentation/widgets/monthly_overview/club_month_summary_card.dart';
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

  testWidgets('ClubMonthSummaryCard exposes its month-details action', (
    tester,
  ) async {
    var tapped = false;
    await _pumpPreview(
      tester,
      locale: const Locale('en'),
      brightness: Brightness.light,
      child: ClubMonthSummaryCard(
        summary: _summary,
        onTap: () => tapped = true,
      ),
    );

    await tester.tap(find.byType(ClubMonthSummaryCard));
    await tester.pump();

    expect(tapped, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('month payment widgets render Bangla in the dark theme', (
    tester,
  ) async {
    PaymentStatus? selectedStatus;
    await _pumpPreview(
      tester,
      locale: const Locale('bn'),
      brightness: Brightness.dark,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ClubMonthPaymentHero(summary: _summary, paymentCount: 1),
          ),
          SliverToBoxAdapter(
            child: ClubMonthPaymentFilterBar(
              filter: const ClubMonthPaymentFilter(),
              shownCount: 1,
              totalCount: 1,
              onStatusChanged: (status) => selectedStatus = status,
              onMoreFilters: () {},
              onClear: () {},
            ),
          ),
          ClubMonthPaymentList(
            payments: [_payment],
            isAdmin: false,
            memberById: (_) => _member,
            onPaymentTap: (_) {},
            onStatusChanged: (_, _) {},
            onDelete: (_) {},
          ),
        ],
      ),
    );

    expect(find.text('অপেক্ষমাণ'), findsWidgets);
    expect(find.text('নগদ'), findsOneWidget);
    expect(find.text('পরিশোধিত'), findsWidgets);

    await tester.tap(find.text('অপেক্ষমাণ').last);
    await tester.pump();

    expect(selectedStatus, PaymentStatus.pending);
    expect(tester.takeException(), isNull);
  });
}

final _summary = ClubMonthSummary(
  month: DateTime(2026, 8),
  memberCount: 1,
  target: 5000,
  collected: 5000,
  pending: 0,
  rejected: 0,
);

const _member = ClubMember(
  id: 'member-1',
  name: 'জে বি জেসন',
  email: 'member@fundora.app',
  profilePic: '',
  role: 'member',
);

final _payment = ClubPayment(
  id: 'payment-1',
  userId: 'member-1',
  amount: 5000,
  month: '2026-08',
  status: PaymentStatus.paid,
  paymentMethod: PaymentMethod.cash,
  submittedBy: 'admin',
  submittedAt: DateTime(2026, 8, 5, 10, 30),
);

Future<void> _pumpPreview(
  WidgetTester tester, {
  required Locale locale,
  required Brightness brightness,
  required Widget child,
}) async {
  tester.view.physicalSize = const Size(390, 1000);
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
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: MyColor.primary,
              brightness: brightness,
            ),
          ),
          home: Scaffold(body: child),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}
