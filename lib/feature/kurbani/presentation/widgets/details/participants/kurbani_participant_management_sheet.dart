import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_participant.dart';
import 'package:fclub/feature/kurbani/presentation/provider/kurbani_event_provider.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/details/participants/kurbani_candidate_tile.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/details/participants/kurbani_contribution_dialog.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/details/participants/kurbani_participant_tile.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_section_header.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_sheet_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class KurbaniParticipantManagementSheet extends StatefulWidget {
  const KurbaniParticipantManagementSheet({super.key});

  @override
  State<KurbaniParticipantManagementSheet> createState() =>
      _KurbaniParticipantManagementSheetState();
}

class _KurbaniParticipantManagementSheetState
    extends State<KurbaniParticipantManagementSheet> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<KurbaniEventProvider>().loadAvailableParticipants();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KurbaniEventProvider>();
    final colors = Theme.of(context).colorScheme;
    final query = _query.trim().toLowerCase();
    final candidates = provider.availableParticipants
        .where(
          (item) =>
              query.isEmpty ||
              item.username.toLowerCase().contains(query) ||
              item.email.toLowerCase().contains(query),
        )
        .toList(growable: false);
    return DraggableScrollableSheet(
      initialChildSize: .9,
      minChildSize: .58,
      maxChildSize: .96,
      expand: false,
      snap: true,
      snapSizes: const [.58, .9],
      builder: (context, scrollController) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
            top: BorderSide(
              color: KurbaniPalette.emerald.withValues(alpha: .28),
            ),
          ),
        ),
        child: Column(
          children: [
            KurbaniSheetHeader(
              kicker: 'kurbani_participants_kicker'.tr(),
              title: 'kurbani_manage_participants'.tr(),
              icon: Icons.groups_rounded,
              accent: KurbaniPalette.emerald,
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(18, 17, 18, 32),
                children: [
                  KurbaniSectionHeader(
                    title: 'kurbani_current_participants'.tr(),
                    subtitle: 'kurbani_participant_count'.tr(
                      namedArgs: {'count': '${provider.participants.length}'},
                    ),
                    icon: Icons.people_alt_rounded,
                    accent: KurbaniPalette.emerald,
                  ),
                  const SizedBox(height: 11),
                  ...provider.participants.map(
                    (participant) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: KurbaniParticipantTile(
                        participant: participant,
                        enabled: !provider.isSubmitting,
                        onEdit: () => _editParticipant(participant),
                        onRemove: () => _removeParticipant(participant),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  KurbaniSectionHeader(
                    title: 'kurbani_add_from_group'.tr(),
                    subtitle: 'kurbani_add_from_group_hint'.tr(),
                    icon: Icons.person_add_alt_1_rounded,
                    accent: KurbaniPalette.violet,
                  ),
                  const SizedBox(height: 11),
                  TextField(
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'kurbani_search_members'.tr(),
                      prefixIcon: const Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: 11),
                  if (provider.isLoadingParticipants)
                    const Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (candidates.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        query.isEmpty
                            ? 'kurbani_all_members_added'.tr()
                            : 'kurbani_search_empty'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontFamily: MyString.rubikRegular,
                          fontSize: 11,
                        ),
                      ),
                    )
                  else
                    ...candidates.map(
                      (candidate) => KurbaniCandidateTile(
                        participant: candidate,
                        enabled: !provider.isSubmitting,
                        onAdd: () => _addParticipant(candidate),
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

  Future<void> _addParticipant(KurbaniParticipant participant) async {
    final contribution = await showKurbaniContributionDialog(
      context: context,
      title: 'kurbani_add_member_title'.tr(
        namedArgs: {'name': participant.username},
      ),
      amount: _suggestedContribution(),
      initialStatus: KurbaniPaidStatus.pending,
      allowStatus: false,
    );
    if (contribution == null || !mounted) return;
    await _run(
      () => context.read<KurbaniEventProvider>().addParticipant(
        participant.id,
        contribution.amount,
      ),
    );
  }

  Future<void> _editParticipant(KurbaniParticipant participant) async {
    final result = await showKurbaniContributionDialog(
      context: context,
      title: participant.username,
      amount: participant.contribution,
      initialStatus: participant.paidStatus,
      allowStatus: true,
    );
    if (result == null || !mounted) return;
    await _run(
      () => context.read<KurbaniEventProvider>().updateParticipant(
        userId: participant.id,
        contribution: result.amount,
        paidStatus: result.status,
      ),
    );
  }

  Future<void> _removeParticipant(KurbaniParticipant participant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.person_remove_alt_1_rounded,
          color: KurbaniPalette.rose,
        ),
        title: Text(
          'kurbani_remove_title'.tr(namedArgs: {'name': participant.username}),
        ),
        content: Text('kurbani_remove_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: KurbaniPalette.rose),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('kurbani_remove_participant'.tr()),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _run(
        () => context.read<KurbaniEventProvider>().removeParticipant(
          participant.id,
        ),
      );
    }
  }

  double _suggestedContribution() {
    final participants = context.read<KurbaniEventProvider>().participants;
    if (participants.isEmpty) return 0;
    return participants.first.contribution;
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      if (!mounted) return;
      final key = context.read<KurbaniEventProvider>().actionError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text((key ?? 'kurbani_error_unknown').tr())),
      );
    }
  }
}
