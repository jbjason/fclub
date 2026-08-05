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
      if (mounted) context.read<ClubProvider>().loadAvailableMembers();
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
                          'Manage Club members',
                          style: TextStyle(
                            fontFamily: MyString.poppinsBold,
                            fontSize: 16.sp,
                          ),
                        ),
                        Text(
                          '${provider.members.length} active members · admin only',
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
                  const _SectionTitle('CURRENT MEMBERS'),
                  SizedBox(height: 5.h),
                  ...provider.members.map(
                    (member) => ClubMemberTile(
                      member: member,
                      canRemove: !provider.isSubmitting,
                      onRemove: () => _confirmRemove(context, member),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  const _SectionTitle('ADD FROM FUNDORA'),
                  SizedBox(height: 9.h),
                  TextField(
                    onChanged: (value) => setState(() => _query = value),
                    decoration: const InputDecoration(
                      hintText: 'Search name or email',
                      prefixIcon: Icon(Icons.search_rounded),
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
                            label: const Text('Try again'),
                          ),
                        ],
                      ),
                    )
                  else if (candidates.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: Text(
                        _query.isEmpty
                            ? 'Everyone is already in this group.'
                            : 'No matching Fundora users.',
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

  Future<void> _confirmRemove(BuildContext context, ClubMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Remove ${member.name}?'),
        content: const Text(
          'They will lose access to this group. Existing payment records remain.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
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
