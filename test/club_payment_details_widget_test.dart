import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/feature/club/data/model/club_member.dart';
import 'package:fclub/feature/club/data/model/club_member_payment_filter.dart';
import 'package:fclub/feature/club/data/model/club_member_payment_summary.dart';
import 'package:fclub/feature/club/data/model/club_payment.dart';
import 'package:fclub/feature/club/presentation/widgets/monthly_overview/club_payment_card.dart';
import 'package:fclub/feature/club/presentation/widgets/payment_details/club_member_payment_hero.dart';
import 'package:fclub/feature/club/presentation/widgets/payment_details/club_payment_detail_tile.dart';
import 'package:fclub/feature/club/presentation/widgets/payment_details/club_payment_details_filter_bar.dart';
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

  testWidgets('ClubPaymentCard exposes the member details action', (
    tester,
  ) async {
    var tapped = false;
    await _pumpPreview(
      tester,
      locale: const Locale('en'),
      brightness: Brightness.light,
      child: ClubPaymentCard(
        payment: _payment,
        member: _member,
        isAdmin: false,
        onTap: () => tapped = true,
        onStatusChanged: (_) {},
      ),
    );

    await tester.tap(find.byType(ClubPaymentCard));
    await tester.pump();

    expect(tapped, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('payment detail widgets render Bangla in the dark theme', (
    tester,
  ) async {
    PaymentStatus? selectedStatus;
    await _pumpPreview(
      tester,
      locale: const Locale('bn'),
      brightness: Brightness.dark,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const ClubMemberPaymentHero(
              userId: 'member-1',
              name: 'জে বি জেসন',
              email: 'member@fundora.app',
              summary: ClubMemberPaymentSummary(
                totalPaid: 5000,
                totalPending: 0,
                totalRejected: 0,
                entryCount: 1,
              ),
            ),
            ClubPaymentDetailsFilterBar(
              filter: const ClubMemberPaymentFilter(),
              shownCount: 1,
              totalCount: 1,
              onStatusChanged: (status) => selectedStatus = status,
              onMoreFilters: () {},
              onClear: () {},
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ClubPaymentDetailTile(payment: _payment),
            ),
          ],
        ),
      ),
    );

    expect(find.text('মোট পরিশোধিত'), findsOneWidget);
    expect(find.text('নগদ'), findsOneWidget);
    expect(find.text('পরিশোধিত'), findsWidgets);

    await tester.tap(find.text('অপেক্ষমাণ').last);
    await tester.pump();

    expect(selectedStatus, PaymentStatus.pending);
    expect(tester.takeException(), isNull);
  });
}

const _member = ClubMember(
  id: 'member-1',
  name: 'JB Jason',
  email: 'member@fundora.app',
  profilePic: '',
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
  note: 'August contribution',
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
