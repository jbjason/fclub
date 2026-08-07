import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/feature/home/data/models/user_group.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_gateway_actions.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_gateway_header.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_gateway_hero.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_gateway_section_label.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_privacy_note.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/user_groups_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupGatewayContent extends StatelessWidget {
  const GroupGatewayContent({
    super.key,
    required this.pinController,
    required this.pinFocusNode,
    required this.isJoining,
    required this.onPinChanged,
    required this.onJoin,
    required this.onCreate,
    required this.showUserGroups,
    required this.groups,
    required this.isLoadingGroups,
    required this.hasGroupsError,
    required this.selectingGroupId,
    required this.onSelectGroup,
    required this.onRetryGroups,
    required this.isSigningOut,
    required this.onSignOut,
  });

  final TextEditingController pinController;
  final FocusNode pinFocusNode;
  final bool isJoining;
  final ValueChanged<String> onPinChanged;
  final VoidCallback onJoin;
  final VoidCallback onCreate;
  final bool showUserGroups;
  final List<UserGroup> groups;
  final bool isLoadingGroups;
  final bool hasGroupsError;
  final String? selectingGroupId;
  final ValueChanged<UserGroup> onSelectGroup;
  final VoidCallback onRetryGroups;
  final bool isSigningOut;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = MediaQuery.sizeOf(context).height < 720;
        final maxContentWidth = constraints.maxWidth >= 920 ? 900.0 : 720.0;
        final horizontalPadding = constraints.maxWidth < 360 ? 14.w : 20.w;
        final majorGap = compact ? 18.h : 24.h;

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            compact ? 12.h : 16.h,
            horizontalPadding,
            compact ? 22.h : 28.h,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GroupGatewayHeader(
                    isSigningOut: isSigningOut,
                    onSignOut: onSignOut,
                  ),
                  SizedBox(height: majorGap),
                  const GroupGatewayHero(),
                  if (showUserGroups) ...[
                    SizedBox(height: majorGap),
                    UserGroupsSection(
                      groups: groups,
                      isLoading: isLoadingGroups,
                      hasError: hasGroupsError,
                      selectingGroupId: selectingGroupId,
                      onSelect: onSelectGroup,
                      onRetry: onRetryGroups,
                    ),
                  ],
                  SizedBox(height: majorGap),
                  GroupGatewaySectionLabel(
                    label: 'group_gateway_choose_path'.tr(),
                  ),
                  SizedBox(height: 11.h),
                  GroupGatewayActions(
                    controller: pinController,
                    focusNode: pinFocusNode,
                    isJoining: isJoining,
                    onPinChanged: onPinChanged,
                    onJoin: onJoin,
                    onCreate: onCreate,
                  ),
                  SizedBox(height: compact ? 17.h : 22.h),
                  const GroupPrivacyNote(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
