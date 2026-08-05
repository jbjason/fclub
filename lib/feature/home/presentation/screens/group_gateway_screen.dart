import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/config/router/app_router.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/services/auth/firebase_auth_service.dart';
import 'package:fclub/feature/home/data/models/group_failure.dart';
import 'package:fclub/feature/home/data/models/group_user.dart';
import 'package:fclub/feature/home/data/models/joined_group.dart';
import 'package:fclub/feature/home/data/repositories/group_repository.dart';
import 'package:fclub/feature/home/presentation/group_failure_localization.dart';
import 'package:fclub/feature/home/presentation/provider/group_join_provider.dart';
import 'package:fclub/feature/home/presentation/provider/group_session_provider.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_choice_divider.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_create_card.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_gateway_backdrop.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_gateway_header.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_gateway_hero.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_gateway_section_label.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_join_card.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_join_result_dialog.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_privacy_note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// Landing page shown after authentication and before a group is selected.
class GroupGatewayScreen extends StatefulWidget {
  const GroupGatewayScreen({
    super.key,
    this.onJoinGroup,
    this.onCreateGroup,
    this.currentUser,
  });

  final VoidCallback? onJoinGroup;
  final VoidCallback? onCreateGroup;

  /// Optional injection point used by previews and widget tests.
  final GroupUser? currentUser;

  @override
  State<GroupGatewayScreen> createState() => _GroupGatewayScreenState();
}

class _GroupGatewayScreenState extends State<GroupGatewayScreen> {
  final _pinController = TextEditingController();
  final _pinFocusNode = FocusNode();
  GroupJoinProvider? _joinProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.onJoinGroup == null && _joinProvider == null) {
      _joinProvider = GroupJoinProvider(context.read<GroupRepository>());
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    _joinProvider?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = _joinProvider;
    if (provider == null) return _buildGateway(context, isJoining: false);

    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) =>
          _buildGateway(context, isJoining: provider.isJoining),
    );
  }

  Widget _buildGateway(BuildContext context, {required bool isJoining}) {
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
                          GroupJoinCard(
                            controller: _pinController,
                            focusNode: _pinFocusNode,
                            isJoining: isJoining,
                            onChanged: (_) => _joinProvider?.clearFailure(),
                            onJoin: _join,
                          ),
                          SizedBox(height: 18.h),
                          const GroupChoiceDivider(),
                          SizedBox(height: 18.h),
                          GroupCreateCard(
                            onCreate:
                                widget.onCreateGroup ??
                                () => Navigator.pushNamed(
                                  context,
                                  AppRouteName.groupCreate,
                                ),
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

  Future<void> _join() async {
    if (widget.onJoinGroup != null) {
      widget.onJoinGroup!();
      return;
    }

    FocusScope.of(context).unfocus();
    final provider = _joinProvider!;
    final user = widget.currentUser ?? _firebaseGroupUser();
    final result = await provider.join(
      pinCode: _pinController.text,
      user: user,
    );
    if (!mounted) return;

    if (result != null) {
      _activateGroup(result);
      await _showJoinSuccess(result);
      return;
    }
    await _showJoinFailure(
      provider.failure ?? const GroupFailure(GroupFailureCode.unknown),
    );
  }

  void _activateGroup(JoinedGroup group) {
    try {
      context.read<GroupSessionProvider>().activateJoined(group);
    } on ProviderNotFoundException {
      // Widget previews and focused tests can render the gateway in isolation.
    }
  }

  GroupUser _firebaseGroupUser() {
    final firebaseUser = context.read<FirebaseAuthService>().currentUser;
    final email = firebaseUser?.email?.trim() ?? '';
    final emailName = email.isEmpty ? '' : email.split('@').first;
    final displayName = firebaseUser?.displayName?.trim() ?? '';

    return GroupUser(
      id: firebaseUser?.uid ?? '',
      username: displayName.isNotEmpty
          ? displayName
          : emailName.isNotEmpty
          ? emailName
          : 'Fundora Member',
      profilePic: firebaseUser?.photoURL ?? '',
      email: email,
    );
  }

  Future<void> _showJoinSuccess(JoinedGroup group) {
    final alreadyMember = group.alreadyMember;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: GroupJoinResultDialog(
          icon: alreadyMember
              ? Icons.verified_rounded
              : Icons.how_to_reg_rounded,
          accent: alreadyMember ? MyColor.secondary : MyColor.success,
          title: alreadyMember
              ? 'group_join_existing_title'.tr()
              : 'group_join_success_title'.tr(),
          groupName: group.name,
          description: alreadyMember
              ? 'group_join_existing_description'.tr()
              : 'group_join_success_description'.tr(),
          actionLabel: 'group_join_continue'.tr(),
          onAction: () {
            Navigator.of(dialogContext).pop();
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRouteName.home, (_) => false);
          },
        ),
      ),
    );
  }

  Future<void> _showJoinFailure(GroupFailure failure) {
    final isNoMatch = failure.code == GroupFailureCode.groupNotFound;
    final isInvalid = failure.code == GroupFailureCode.invalidInput;
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => GroupJoinResultDialog(
        icon: isNoMatch ? Icons.key_off_rounded : Icons.error_outline_rounded,
        accent: MyColor.tertiary,
        title: isNoMatch
            ? 'group_join_not_found_title'.tr()
            : isInvalid
            ? 'group_join_invalid_title'.tr()
            : 'group_join_error_title'.tr(),
        description: isNoMatch
            ? 'group_join_not_found_description'.tr()
            : isInvalid
            ? 'group_join_invalid_description'.tr()
            : failure.localizationKey.tr(),
        actionLabel: 'group_join_try_again'.tr(),
        onAction: () {
          Navigator.of(dialogContext).pop();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _pinFocusNode.requestFocus();
          });
        },
      ),
    );
  }
}
