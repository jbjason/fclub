import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/config/theme/app_theme.dart';
import 'package:fclub/core/services/locale_service.dart';
import 'package:fclub/feature/home/data/models/create_group_request.dart';
import 'package:fclub/feature/home/data/models/created_group.dart';
import 'package:fclub/feature/home/data/models/group_failure.dart';
import 'package:fclub/feature/home/data/models/group_user.dart';
import 'package:fclub/feature/home/data/models/joined_group.dart';
import 'package:fclub/feature/home/data/repositories/group_repository.dart';
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

  testWidgets('shows no-match dialog and then joins with the correct PIN', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _GatewayJoinRepository();
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('bn')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        saveLocale: false,
        child: MultiProvider(
          providers: [
            Provider<GroupRepository>.value(value: repository),
            ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, _) => MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              theme: AppTheme.light(context),
              home: const GroupGatewayScreen(
                currentUser: GroupUser(
                  id: 'user-id',
                  username: 'Aurora Member',
                  profilePic: '',
                  email: 'member@fundora.app',
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('group-secret-code-field')),
      'wrong-1',
    );
    await tester.ensureVisible(find.text('Unlock group'));
    await tester.tap(find.text('Unlock group'));
    await tester.pumpAndSettle();

    expect(find.text("That code didn't match"), findsOneWidget);
    expect(repository.joinAttempts, 1);

    await tester.tap(find.byKey(const Key('group-join-dialog-action')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('group-secret-code-field')),
      'A7KD-92Q',
    );
    await tester.ensureVisible(find.text('Unlock group'));
    await tester.tap(find.text('Unlock group'));
    await tester.pumpAndSettle();

    expect(find.text("You're in!"), findsOneWidget);
    expect(find.text('Aurora Circle'), findsOneWidget);
    expect(repository.joinAttempts, 2);
    expect(repository.lastEmail, 'member@fundora.app');
    expect(tester.takeException(), isNull);
  });
}

class _GatewayJoinRepository implements GroupRepository {
  int joinAttempts = 0;
  String? lastEmail;

  @override
  Future<JoinedGroup> joinGroup({
    required String pinCode,
    required GroupUser user,
  }) async {
    joinAttempts++;
    lastEmail = user.email;
    if (pinCode != 'A7KD-92Q') {
      throw const GroupFailure(GroupFailureCode.groupNotFound);
    }
    return const JoinedGroup(
      id: 'group-id',
      name: 'Aurora Circle',
      pinCode: 'A7KD-92Q',
      alreadyMember: false,
    );
  }

  @override
  Future<CreatedGroup> createGroup(CreateGroupRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<List<GroupUser>> getUsers() {
    throw UnimplementedError();
  }
}
