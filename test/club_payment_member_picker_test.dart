import 'package:fclub/feature/club/data/model/club_member.dart';
import 'package:fclub/feature/club/presentation/widgets/add_entry/club_payment_member_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const admin = ClubMember(
    id: 'admin-id',
    name: 'Admin User',
    email: 'admin@example.com',
    profilePic: '',
    role: 'admin',
  );
  const memberOne = ClubMember(
    id: 'member-one',
    name: 'Member One',
    email: 'one@example.com',
    profilePic: '',
    role: 'member',
  );
  const memberTwo = ClubMember(
    id: 'member-two',
    name: 'Member Two',
    email: 'two@example.com',
    profilePic: '',
    role: 'member',
  );
  const members = [admin, memberOne, memberTwo];

  testWidgets('admin sees every group member and the add-member action', (
    tester,
  ) async {
    String? selectedId;
    var managePressed = false;

    await tester.pumpWidget(
      _testApp(
        ClubPaymentMemberPicker(
          members: members,
          currentMember: admin,
          isAdmin: true,
          selectedMemberId: admin.id,
          onSelected: (id) => selectedId = id,
          onManageMembers: () => managePressed = true,
        ),
      ),
    );

    expect(find.text('Admin User'), findsOneWidget);
    expect(find.text('Member One'), findsOneWidget);
    expect(find.text('Member Two'), findsOneWidget);
    expect(find.text('Add member'), findsOneWidget);

    await tester.tap(find.text('Member Two'));
    await tester.tap(find.text('Add member'));

    expect(selectedId, memberTwo.id);
    expect(managePressed, isTrue);
  });

  testWidgets('member sees only the locked signed-in member', (tester) async {
    await tester.pumpWidget(
      _testApp(
        ClubPaymentMemberPicker(
          members: members,
          currentMember: memberOne,
          isAdmin: false,
          selectedMemberId: memberOne.id,
          onSelected: (_) {},
          onManageMembers: () {},
        ),
      ),
    );

    expect(find.text('Member One'), findsOneWidget);
    expect(find.text('Admin User'), findsNothing);
    expect(find.text('Member Two'), findsNothing);
    expect(find.text('Add member'), findsNothing);
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
  });
}

Widget _testApp(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, _) => MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    ),
  );
}
