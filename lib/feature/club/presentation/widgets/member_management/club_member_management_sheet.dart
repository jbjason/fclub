import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/club/data/model/club_member.dart';
import 'package:fclub/feature/club/presentation/provider/club_provider.dart';
import 'package:fclub/feature/club/presentation/widgets/member_management/club_member_candidate_tile.dart';
import 'package:fclub/feature/club/presentation/widgets/member_management/club_member_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ClubMemberManagementSheet extends StatefulWidget {
  const ClubMemberManagementSheet({super.key});

  @override
  State<ClubMemberManagementSheet> createState() =>
      _ClubMemberManagementSheetState();
}

class _ClubMemberManagementSheetState extends State<ClubMemberManagementSheet> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<ClubProvider>();
      if (provider.isAdmin) provider.loadAvailableMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClubProvider>();
    final colors = Theme.of(context).colorScheme;
    final existingIds = provider.members.map((member) => member.id).toSet();
    final existingEmails = provider.members
        .map((member) => member.email.trim().toLowerCase())
        .where((email) => email.isNotEmpty)
        .toSet();
    final candidates = provider.availableMembers
        .where((member) {
          final email = member.email.trim().toLowerCase();
          if (existingIds.contains(member.id) ||
              (email.isNotEmpty && existingEmails.contains(email))) {
            return false;
          }
          final query = _query.trim().toLowerCase();
          return query.isEmpty ||
              member.name.toLowerCase().contains(query) ||
              member.email.toLowerCase().contains(query);
        })
        .toList(growable: false);

    return DraggableScrollableSheet(
      initialChildSize: .88,
      minChildSize: .55,
      maxChildSize: .96,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Container(
              width: 44.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colors.outlineVariant,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 15.h, 10.w, 8.h),
              child: Row(
                children: [
                  Container(
                    width: 42.r,
                    height: 42.r,
                    decoration: BoxDecoration(
                      color: MyColor.primary.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: const Icon(
                      Icons.group_work_rounded,
                      color: MyColor.primary,
                    ),
                  ),
                  SizedBox(width: 11.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'club_manage_members'.tr(),
                          style: TextStyle(
                            fontFamily: MyString.poppinsBold,
                            fontSize: 16.sp,
                          ),
                        ),
                        Text(
                          'club_manage_members_subtitle'.tr(
                            namedArgs: {
                              'count': provider.members.length.toString(),
                            },
                          ),
                          style: TextStyle(
                            fontFamily: MyString.rubikRegular,
                            fontSize: 10.sp,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 28.h),
                children: [
                  _SectionTitle('club_current_members'.tr()),
                  SizedBox(height: 5.h),
                  ...provider.members.map(
                    (member) => ClubMemberTile(
                      member: member,
                      isAdmin: member.id == provider.adminId,
                      canManage: !provider.isSubmitting,
                      onTransferAdmin: () => _confirmTransfer(context, member),
                      onRemove: () => _confirmRemove(context, member),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _SectionTitle('club_add_from_fundora'.tr()),
                  SizedBox(height: 9.h),
                  TextField(
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'club_search_name_email'.tr(),
                      prefixIcon: const Icon(Icons.search_rounded),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  if (provider.isLoadingCandidates)
                    const Padding(
                      padding: EdgeInsets.all(28),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (provider.actionError != null)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 18.h),
                      child: Column(
                        children: [
                          Text(
                            provider.actionError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: MyColor.error),
                          ),
                          SizedBox(height: 8.h),
                          TextButton.icon(
                            onPressed: provider.loadAvailableMembers,
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text('group_retry'.tr()),
                          ),
                        ],
                      ),
                    )
                  else if (candidates.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: Text(
                        _query.isEmpty
                            ? 'club_everyone_added'.tr()
                            : 'club_no_matching_users'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    )
                  else
                    ...candidates.map(
                      (candidate) => ClubMemberCandidateTile(
                        member: candidate,
                        onAdd: () => _add(context, candidate),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _add(BuildContext context, ClubMemberCandidate candidate) async {
    try {
      await context.read<ClubProvider>().addMember(candidate);
    } catch (error) {
      if (context.mounted) _showError(context, error);
    }
  }

  Future<void> _confirmTransfer(BuildContext context, ClubMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.admin_panel_settings_rounded,
          color: MyColor.primary,
        ),
        title: Text(
          'club_transfer_admin_title'.tr(namedArgs: {'name': member.name}),
        ),
        content: Text(
          'club_transfer_admin_message'.tr(namedArgs: {'name': member.name}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('cancel'.tr()),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.swap_horiz_rounded),
            label: Text('club_transfer_admin_confirm'.tr()),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<ClubProvider>().transferAdmin(member);
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'club_transfer_admin_success'.tr(namedArgs: {'name': member.name}),
          ),
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      if (context.mounted) _showError(context, error);
    }
  }

  Future<void> _confirmRemove(BuildContext context, ClubMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'club_remove_member_title'.tr(namedArgs: {'name': member.name}),
        ),
        content: Text('club_remove_member_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('club_remove_member'.tr()),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await context.read<ClubProvider>().removeMember(member);
    } catch (error) {
      if (context.mounted) _showError(context, error);
    }
  }

  void _showError(BuildContext context, Object error) {
    final message = context.read<ClubProvider>().actionError ?? '$error';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: MyString.poppinsBold,
        color: MyColor.primary,
        fontSize: 9.sp,
        letterSpacing: 1.1,
      ),
    );
  }
}
