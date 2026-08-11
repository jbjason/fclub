import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_member_balance.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_participant.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_avatar.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_card_shell.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:flutter/material.dart';

class KurbaniBalanceTile extends StatelessWidget {
  const KurbaniBalanceTile({
    super.key,
    required this.balance,
    required this.participant,
  });

  final KurbaniMemberBalance balance;
  final KurbaniParticipant? participant;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = balance.isOwedByGroup
        ? KurbaniPalette.emerald
        : balance.owesGroup
        ? KurbaniPalette.rose
        : KurbaniPalette.gold;
    final label = balance.isOwedByGroup
        ? 'kurbani_gets'.tr(
            namedArgs: {'amount': CurrencyFormatter.format(balance.net)},
          )
        : balance.owesGroup
        ? 'kurbani_owes'.tr(
            namedArgs: {'amount': CurrencyFormatter.format(balance.net.abs())},
          )
        : 'kurbani_settled'.tr();
    return KurbaniCardShell(
      accent: accent,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          KurbaniAvatar(
            id: balance.memberId,
            name: balance.memberName,
            photoUrl: participant?.profilePic ?? '',
            size: 44,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  balance.memberName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: MyString.poppinsBold,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'kurbani_member_credit'.tr(
                    namedArgs: {
                      'contribution': CurrencyFormatter.format(
                        balance.contributed,
                      ),
                      'expenses': CurrencyFormatter.format(
                        balance.paidExpenses,
                      ),
                    },
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontFamily: MyString.rubikRegular,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: accent,
                fontFamily: MyString.rubikMedium,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
