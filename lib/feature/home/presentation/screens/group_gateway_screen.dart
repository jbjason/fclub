import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/config/router/app_router.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/services/auth/firebase_auth_service.dart';
import 'package:fclub/feature/auth/presentation/provider/auth_session_provider.dart';
import 'package:fclub/feature/home/data/models/group_failure.dart';
import 'package:fclub/feature/home/data/models/group_user.dart';
import 'package:fclub/feature/home/data/models/joined_group.dart';
import 'package:fclub/feature/home/data/models/user_group.dart';
import 'package:fclub/feature/home/data/repositories/group_repository.dart';
import 'package:fclub/feature/home/presentation/group_failure_localization.dart';
import 'package:fclub/feature/home/presentation/provider/group_join_provider.dart';
import 'package:fclub/feature/home/presentation/provider/group_session_provider.dart';
import 'package:fclub/feature/home/presentation/provider/user_groups_provider.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_gateway_backdrop.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_gateway_content.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_join_result_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Landing page shown after authentication and before a group is selected.
class GroupGatewayScreen extends StatefulWidget {
  const GroupGatewayScreen({
    super.key,
    this.onJoinGroup,
    this.onCreateGroup,
    this.onSignOut,
    this.currentUser,
  });

  final VoidCallback? onJoinGroup;
  final VoidCallback? onCreateGroup;
  final VoidCallback? onSignOut;

  /// Optional injection point used by previews and widget tests.
  final GroupUser? currentUser;

  @override
  State<GroupGatewayScreen> createState() => _GroupGatewayScreenState();
}

class _GroupGatewayScreenState extends State<GroupGatewayScreen> {
  final _pinController = TextEditingController();
  final _pinFocusNode = FocusNode();
  GroupJoinProvider? _joinProvider;
  UserGroupsProvider? _userGroupsProvider;
  GroupUser? _resolvedUser;
  bool _isSigningOut = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.onJoinGroup == null && _joinProvider == null) {
      final repository = context.read<GroupRepository>();
      _resolvedUser = widget.currentUser ?? _firebaseGroupUser();
      _joinProvider = GroupJoinProvider(repository);
      if (_resolvedUser!.id.isNotEmpty) {
        _userGroupsProvider = UserGroupsProvider(repository)
          ..load(userId: _resolvedUser!.id);
      }
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    _joinProvider?.dispose();
    _userGroupsProvider?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = _joinProvider;
    if (provider == null) return _buildUserGroupsListener(isJoining: false);

    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) =>
          _buildUserGroupsListener(isJoining: provider.isJoining),
    );
  }

  Widget _buildUserGroupsListener({required bool isJoining}) {
    final provider = _userGroupsProvider;
    if (provider == null) return _buildGateway(isJoining: isJoining);

    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) => _buildGateway(isJoining: isJoining),
    );
  }

  Widget _buildGateway({required bool isJoining}) {
    final colorScheme = Theme.of(context).colorScheme;
    final groupsProvider = _userGroupsProvider;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          const Positioned.fill(child: GroupGatewayBackdrop()),
          SafeArea(
            child: GroupGatewayContent(
              pinController: _pinController,
              pinFocusNode: _pinFocusNode,
              isJoining: isJoining,
              onPinChanged: (_) => _joinProvider?.clearFailure(),
              onJoin: _join,
              onCreate:
                  widget.onCreateGroup ??
                  () => Navigator.pushNamed(context, AppRouteName.groupCreate),
              showUserGroups: groupsProvider != null,
              groups: groupsProvider?.groups ?? const [],
              isLoadingGroups: groupsProvider?.isLoading ?? false,
              hasGroupsError: groupsProvider?.loadFailure != null,
              selectingGroupId: groupsProvider?.selectingGroupId,
              onSelectGroup: _selectGroup,
              onRetryGroups: _loadUserGroups,
              isSigningOut: _isSigningOut,
              onSignOut: _signOut,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    if (_isSigningOut) return;

    final injectedAction = widget.onSignOut;
    if (injectedAction != null) {
      injectedAction();
      return;
    }

    setState(() => _isSigningOut = true);
    final result = await context.read<AuthSessionProvider>().signOut();
    if (!mounted) return;

    setState(() => _isSigningOut = false);
    if (!result.isSuccess) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result.message)));
      return;
    }

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRouteName.authGate, (_) => false);
  }

  Future<void> _join() async {
    if (widget.onJoinGroup != null) {
      widget.onJoinGroup!();
      return;
    }

    FocusScope.of(context).unfocus();
    final provider = _joinProvider!;
    final user = _resolvedUser ?? widget.currentUser ?? _firebaseGroupUser();
    final result = await provider.join(
      pinCode: _pinController.text,
      user: user,
    );
    if (!mounted) return;

    if (result != null) {
      await _activateJoinedGroup(result, userId: user.id);
      await _showJoinSuccess(result);
      return;
    }
    await _showJoinFailure(
      provider.failure ?? const GroupFailure(GroupFailureCode.unknown),
    );
  }

  Future<void> _activateJoinedGroup(
    JoinedGroup group, {
    required String userId,
  }) async {
    try {
      await context.read<GroupSessionProvider>().activateJoined(
        group: group,
        userId: userId,
      );
    } on ProviderNotFoundException {
      // Widget previews and focused tests can render the gateway in isolation.
    }
  }

  Future<void> _selectGroup(UserGroup group) async {
    final provider = _userGroupsProvider;
    final user = _resolvedUser;
    if (provider == null || user == null) return;

    final selected = await provider.select(userId: user.id, groupId: group.id);
    if (!mounted) return;
    if (selected == null) {
      final failure = provider.selectionFailure;
      final message = failure?.code == GroupFailureCode.groupNotFound
          ? 'group_membership_missing'.tr()
          : (failure ?? const GroupFailure(GroupFailureCode.unknown))
                .localizationKey
                .tr();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    try {
      await context.read<GroupSessionProvider>().activateMembership(
        group: selected,
        userId: user.id,
      );
    } on ProviderNotFoundException {
      // Widget previews and focused tests can render the gateway in isolation.
    }
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRouteName.home, (_) => false);
  }

  void _loadUserGroups() {
    final userId = _resolvedUser?.id;
    if (userId == null || userId.isEmpty) return;
    _userGroupsProvider?.load(userId: userId);
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
