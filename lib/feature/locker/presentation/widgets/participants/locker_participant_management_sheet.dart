import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/locker/data/models/locker_participant.dart';
import 'package:fclub/feature/locker/presentation/provider/locker_provider.dart';
import 'package:fclub/feature/locker/presentation/widgets/participants/locker_participant_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class LockerParticipantManagementSheet extends StatefulWidget {
  const LockerParticipantManagementSheet({super.key});

  @override
  State<LockerParticipantManagementSheet> createState() =>
      _LockerParticipantManagementSheetState();
}

class _LockerParticipantManagementSheetState
    extends State<LockerParticipantManagementSheet> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LockerProvider>().loadAvailableParticipants();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LockerProvider>();
    final colors = Theme.of(context).colorScheme;
    final normalizedQuery = _query.trim().toLowerCase();
    final candidates = provider.availableParticipants
        .where(
          (participant) =>
              normalizedQuery.isEmpty ||
              participant.username.toLowerCase().contains(normalizedQuery) ||
              participant.email.toLowerCase().contains(normalizedQuery),
        )
        .toList(growable: false);

    return DraggableScrollableSheet(
      initialChildSize: .9,
      minChildSize: .56,
      maxChildSize: .96,
      expand: false,
      snap: true,
      snapSizes: const [.56, .9],
      builder: (context, scrollController) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          border: Border(
            top: BorderSide(color: MyColor.secondary.withValues(alpha: .25)),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Container(
              width: 46.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colors.outlineVariant,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            _SheetHeader(
              participantCount: provider.participants.length,
              onClose: () => Navigator.pop(context),
            ),
            Divider(
              height: 1,
              color: colors.outlineVariant.withValues(alpha: .5),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(18.w, 15.h, 18.w, 32.h),
                children: [
                  _SectionHeader(
                    label: 'locker_current_participants'.tr(),
                    count: provider.participants.length,
                    accent: MyColor.secondary,
                  ),
                  SizedBox(height: 9.h),
                  ...provider.participants.map(
                    (participant) => LockerParticipantTile(
                      participant: participant,
                      isAdmin: participant.id == provider.project?.adminId,
                      canManage: !provider.isSubmitting,
                      canTransferAdmin: provider.isProjectAdmin,
                      onRemove: () => _confirmRemove(context, participant),
                      onTransferAdmin: () =>
                          _confirmTransfer(context, participant),
                    ),
                  ),
                  SizedBox(height: 17.h),
                  _SectionHeader(
                    label: 'locker_add_from_group'.tr(),
                    count: provider.availableParticipants.length,
                    accent: MyColor.primary,
                  ),
                  SizedBox(height: 10.h),
                  TextField(
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'locker_search_name_email'.tr(),
                      prefixIcon: const Icon(Icons.search_rounded),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  if (provider.isLoadingParticipants)
                    const Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (provider.actionError != null)
                    _LoadError(
                      message: provider.actionError!,
                      onRetry: provider.loadAvailableParticipants,
                    )
                  else if (candidates.isEmpty)
                    _EmptyCandidates(hasQuery: normalizedQuery.isNotEmpty)
                  else
                    ...candidates.map(
                      (candidate) => _CandidateTile(
                        participant: candidate,
                        isSubmitting: provider.isSubmitting,
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

  Future<void> _add(BuildContext context, LockerParticipant participant) async {
    await _run(
      context,
      () => context.read<LockerProvider>().addParticipant(participant.id),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    LockerParticipant participant,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.person_remove_alt_1_rounded,
          color: MyColor.error,
        ),
        title: Text(
          'locker_remove_title'.tr(namedArgs: {'name': participant.username}),
        ),
        content: Text('locker_remove_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: MyColor.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('locker_remove_participant'.tr()),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _run(
      context,
      () => context.read<LockerProvider>().removeParticipant(participant.id),
    );
  }

  Future<void> _confirmTransfer(
    BuildContext context,
    LockerParticipant participant,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.admin_panel_settings_rounded,
          color: MyColor.secondary,
        ),
        title: Text(
          'locker_transfer_title'.tr(namedArgs: {'name': participant.username}),
        ),
        content: Text(
          'locker_transfer_message'.tr(
            namedArgs: {'name': participant.username},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('cancel'.tr()),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: MyColor.secondary,
              foregroundColor: MyColor.onSecondary,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.swap_horiz_rounded),
            label: Text('locker_transfer_confirm'.tr()),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<LockerProvider>().transferAdmin(participant.id);
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'locker_transfer_success'.tr(
              namedArgs: {'name': participant.username},
            ),
          ),
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      if (context.mounted) _showError(context, error);
    }
  }

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error) {
      if (context.mounted) _showError(context, error);
    }
  }

  void _showError(BuildContext context, Object error) {
    final message = context.read<LockerProvider>().actionError ?? '$error';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.participantCount, required this.onClose});

  final int participantCount;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 15.h, 9.w, 12.h),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [MyColor.secondary, Color(0xFF5B21B6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15.r),
              boxShadow: [
                BoxShadow(
                  color: MyColor.secondary.withValues(alpha: .2),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.group_work_rounded, color: Colors.white),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'locker_manage_participants'.tr(),
                  style: TextStyle(
                    color: colors.onSurface,
                    fontFamily: MyString.poppinsBold,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'locker_manage_participants_subtitle'.tr(
                    namedArgs: {'count': participantCount.toString()},
                  ),
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontFamily: MyString.rubikRegular,
                    fontSize: 9.5.sp,
                  ),
                ),
              ],
            ),
          ),
          IconButton(onPressed: onClose, icon: const Icon(Icons.close_rounded)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.count,
    required this.accent,
  });

  final String label;
  final int count;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 15.h,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(width: 7.w),
        Expanded(
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: accent,
              fontFamily: MyString.poppinsBold,
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: .8,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: accent,
              fontFamily: MyString.poppinsBold,
              fontSize: 8.sp,
            ),
          ),
        ),
      ],
    );
  }
}

class _CandidateTile extends StatelessWidget {
  const _CandidateTile({
    required this.participant,
    required this.isSubmitting,
    required this.onAdd,
  });

  final LockerParticipant participant;
  final bool isSubmitting;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.fromLTRB(10.w, 8.h, 8.w, 8.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest.withValues(alpha: .8),
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(color: MyColor.primary.withValues(alpha: .15)),
      ),
      child: Row(
        children: [
          LockerParticipantAvatar(participant: participant),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: MyString.poppinsMedium,
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  participant.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontFamily: MyString.rubikRegular,
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 7.w),
          FilledButton.tonalIcon(
            onPressed: isSubmitting ? null : onAdd,
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 17),
            label: Text('locker_add_member'.tr()),
          ),
        ],
      ),
    );
  }
}

class _EmptyCandidates extends StatelessWidget {
  const _EmptyCandidates({required this.hasQuery});

  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 25.h),
      child: Column(
        children: [
          Container(
            width: 50.r,
            height: 50.r,
            decoration: BoxDecoration(
              color: MyColor.secondary.withValues(alpha: .09),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasQuery ? Icons.search_off_rounded : Icons.group_rounded,
              color: MyColor.secondary,
            ),
          ),
          SizedBox(height: 9.h),
          Text(
            (hasQuery ? 'locker_no_matching_members' : 'locker_everyone_added')
                .tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontFamily: MyString.rubikRegular,
              fontSize: 10.5.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 22.h),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: MyColor.error),
          ),
          SizedBox(height: 8.h),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('group_retry'.tr()),
          ),
        ],
      ),
    );
  }
}
