import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_participant.dart';
import 'package:fclub/feature/kurbani/presentation/provider/kurbani_event_provider.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/details/kurbani_empty_state.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/details/settlement/kurbani_balance_tile.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/details/settlement/kurbani_settlement_overview.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_section_header.dart';
import 'package:flutter/material.dart';

class KurbaniSettlementTab extends StatelessWidget {
  const KurbaniSettlementTab({super.key, required this.provider});

  final KurbaniEventProvider provider;

  @override
  Widget build(BuildContext context) {
    final summary = provider.summary;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        KurbaniSettlementOverview(summary: summary),
        const SizedBox(height: 20),
        KurbaniSectionHeader(
          title: 'kurbani_member_settlement'.tr(),
          subtitle: 'kurbani_member_settlement_hint'.tr(),
          icon: Icons.balance_rounded,
          accent: KurbaniPalette.violet,
        ),
        const SizedBox(height: 12),
        if (summary.memberBalances.isEmpty)
          KurbaniEmptyState(
            icon: Icons.people_outline_rounded,
            title: 'kurbani_no_participants_title'.tr(),
            message: 'kurbani_no_participants_message'.tr(),
          )
        else
          ...summary.memberBalances.map(
            (balance) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: KurbaniBalanceTile(
                balance: balance,
                participant: _participant(balance.memberId),
              ),
            ),
          ),
      ],
    );
  }

  KurbaniParticipant? _participant(String id) {
    for (final participant in provider.participants) {
      if (participant.id == id) return participant;
    }
    return null;
  }
}
