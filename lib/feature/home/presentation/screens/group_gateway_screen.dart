import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_choice_divider.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_create_card.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_gateway_backdrop.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_gateway_header.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_gateway_hero.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_gateway_section_label.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_join_card.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_privacy_note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Landing page shown after authentication and before a group is selected.
///
/// Group operations are intentionally delegated through callbacks so this
/// presentation layer stays independent from the future group data flow.
class GroupGatewayScreen extends StatelessWidget {
  const GroupGatewayScreen({super.key, this.onJoinGroup, this.onCreateGroup});

  final VoidCallback? onJoinGroup;
  final VoidCallback? onCreateGroup;

  static void _emptyAction() {}

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          const Positioned.fill(child: GroupGatewayBackdrop()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth = constraints.maxWidth > 720
                    ? 720.0
                    : constraints.maxWidth;

                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: contentWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const GroupGatewayHeader(),
                          SizedBox(height: 26.h),
                          const GroupGatewayHero(),
                          SizedBox(height: 28.h),
                          GroupGatewaySectionLabel(
                            label: 'group_gateway_choose_path'.tr(),
                          ),
                          SizedBox(height: 12.h),
                          GroupJoinCard(onJoin: onJoinGroup ?? _emptyAction),
                          SizedBox(height: 18.h),
                          const GroupChoiceDivider(),
                          SizedBox(height: 18.h),
                          GroupCreateCard(
                            onCreate: onCreateGroup ?? _emptyAction,
                          ),
                          SizedBox(height: 22.h),
                          const GroupPrivacyNote(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
