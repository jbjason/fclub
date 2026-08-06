import 'package:fclub/config/router/app_router.dart';
import 'package:fclub/feature/home/data/models/created_group.dart';
import 'package:fclub/feature/home/presentation/group_pin_generator.dart';
import 'package:fclub/feature/home/presentation/provider/group_creation_provider.dart';
import 'package:fclub/feature/home/presentation/provider/group_session_provider.dart';
import 'package:fclub/feature/home/presentation/widgets/group_create_widgets/group_create_hero.dart';
import 'package:fclub/feature/home/presentation/widgets/group_create_widgets/group_create_page_header.dart';
import 'package:fclub/feature/home/presentation/widgets/group_create_widgets/group_create_submit_bar.dart';
import 'package:fclub/feature/home/presentation/widgets/group_create_widgets/group_created_dialog.dart';
import 'package:fclub/feature/home/presentation/widgets/group_create_widgets/group_creation_loading_overlay.dart';
import 'package:fclub/feature/home/presentation/widgets/group_create_widgets/group_identity_card.dart';
import 'package:fclub/feature/home/presentation/widgets/group_create_widgets/group_members_card.dart';
import 'package:fclub/feature/home/presentation/widgets/group_gateway_widgets/group_gateway_backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class GroupCreateScreen extends StatefulWidget {
  const GroupCreateScreen({super.key});

  @override
  State<GroupCreateScreen> createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends State<GroupCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late final TextEditingController _pinController;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController(text: GroupPinGenerator.generate());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupCreationProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Positioned.fill(child: GroupGatewayBackdrop()),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final contentWidth = constraints.maxWidth > 720
                          ? 720.0
                          : constraints.maxWidth;

                      return SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: contentWidth,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  GroupCreatePageHeader(
                                    onBack: () => Navigator.maybePop(context),
                                  ),
                                  SizedBox(height: 24.h),
                                  const GroupCreateHero(),
                                  SizedBox(height: 18.h),
                                  GroupIdentityCard(
                                    nameController: _nameController,
                                    pinController: _pinController,
                                    onGeneratePin: _generatePin,
                                  ),
                                  SizedBox(height: 18.h),
                                  GroupMembersCard(
                                    creator: provider.creator,
                                    users: provider.visibleUsers,
                                    selectedMemberCount:
                                        provider.selectedMemberCount,
                                    isLoading: provider.isLoadingUsers,
                                    loadFailure: provider.loadFailure,
                                    isSelected: provider.isSelected,
                                    onToggle: provider.toggleUser,
                                    onSearch: provider.search,
                                    onRetry: provider.loadUsers,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                GroupCreateSubmitBar(
                  memberCount: provider.selectedMemberCount,
                  isSubmitting: provider.isSubmitting,
                  failure: provider.submitFailure,
                  onSubmit: _submit,
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: GroupCreationLoadingOverlay(visible: provider.isSubmitting),
          ),
        ],
      ),
    );
  }

  void _generatePin() {
    _pinController.text = GroupPinGenerator.generate();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final result = await context.read<GroupCreationProvider>().submit(
      name: _nameController.text,
      pinCode: _pinController.text,
    );
    if (!mounted || result == null) return;
    await _activateGroup(result);
    await _showSuccess(result);
  }

  Future<void> _activateGroup(CreatedGroup group) async {
    try {
      final userId = context.read<GroupCreationProvider>().creator.id;
      await context.read<GroupSessionProvider>().activateCreated(
        group: group,
        userId: userId,
      );
    } on ProviderNotFoundException {
      // Widget previews and focused tests can render this screen in isolation.
    }
  }

  Future<void> _showSuccess(CreatedGroup group) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: GroupCreatedDialog(
          group: group,
          onContinue: () {
            Navigator.of(dialogContext).pop();
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRouteName.home, (_) => false);
          },
        ),
      ),
    );
  }
}
