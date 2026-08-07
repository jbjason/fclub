import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/feature/club/data/model/club_member.dart';
import 'package:fclub/feature/club/presentation/widgets/member_management/club_member_tile.dart';
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

  testWidgets('admin badge and member transfer action use project authority', (
    tester,
  ) async {
    var transferTapped = false;
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
              body: Column(
                children: [
                  ClubMemberTile(
                    member: _member('project-admin', 'Current Admin'),
                    isAdmin: true,
                    canManage: true,
                    onTransferAdmin: () {},
                    onRemove: () {},
                  ),
                  ClubMemberTile(
                    member: _member('member-id', 'Club Member'),
                    isAdmin: false,
                    canManage: true,
                    onTransferAdmin: () => transferTapped = true,
                    onRemove: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ADMIN'), findsOneWidget);
    final memberActions = find.byKey(
      const ValueKey('club-member-actions-member-id'),
    );
    expect(memberActions, findsOneWidget);

    await tester.tap(memberActions);
    await tester.pumpAndSettle();
    expect(find.text('Make Club admin'), findsOneWidget);

    await tester.tap(find.text('Make Club admin'));
    await tester.pumpAndSettle();
    expect(transferTapped, isTrue);
  });
}

ClubMember _member(String id, String name) {
  return ClubMember(
    id: id,
    name: name,
    email: '$id@fundora.app',
    profilePic: '',
  );
}
