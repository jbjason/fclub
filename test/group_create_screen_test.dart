import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/config/theme/app_theme.dart';
import 'package:fclub/feature/home/data/models/create_group_request.dart';
import 'package:fclub/feature/home/data/models/created_group.dart';
import 'package:fclub/feature/home/data/models/group_user.dart';
import 'package:fclub/feature/home/data/models/joined_group.dart';
import 'package:fclub/feature/home/data/repositories/group_repository.dart';
import 'package:fclub/feature/home/presentation/provider/group_creation_provider.dart';
import 'package:fclub/feature/home/presentation/screens/group_create_screen.dart';
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

  testWidgets('selects members and completes the create flow', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _ScreenFakeRepository();
    final provider = GroupCreationProvider(
      repository: repository,
      signedInUser: const GroupUser(
        id: 'creator-id',
        username: 'Creator',
        profilePic: '',
        email: 'creator@fundora.app',
      ),
    );
    await provider.loadUsers();

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('bn')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        saveLocale: false,
        child: ChangeNotifierProvider.value(
          value: provider,
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, _) => MaterialApp(
              debugShowCheckedModeBanner: false,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              theme: AppTheme.light(context),
              home: const GroupCreateScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create your group'), findsOneWidget);
    expect(find.text('Creator'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Aurora Circle');
    await tester.ensureVisible(find.byKey(const Key('group-member-member-id')));
    await tester.tap(find.byKey(const Key('group-member-member-id')));
    await tester.tap(find.byKey(const Key('create-group-submit-button')));
    await tester.pumpAndSettle();

    expect(repository.lastRequest?.name, 'Aurora Circle');
    expect(repository.lastRequest?.members.single.id, 'member-id');
    expect(find.text('Your circle is ready!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _ScreenFakeRepository implements GroupRepository {
  CreateGroupRequest? lastRequest;

  @override
  Future<CreatedGroup> createGroup(CreateGroupRequest request) async {
    lastRequest = request;
    return CreatedGroup(
      id: 'created-group-id',
      name: request.name,
      pinCode: request.pinCode,
      memberCount: request.members.length + 1,
    );
  }

  @override
  Future<List<GroupUser>> getUsers() async {
    return const [
      GroupUser(
        id: 'creator-id',
        username: 'Creator',
        profilePic: '',
        email: 'creator@fundora.app',
      ),
      GroupUser(
        id: 'member-id',
        username: 'Aurora Member',
        profilePic: '',
        email: 'aurora@fundora.app',
      ),
    ];
  }

  @override
  Future<JoinedGroup> joinGroup({
    required String pinCode,
    required GroupUser user,
  }) {
    throw UnimplementedError();
  }
}
