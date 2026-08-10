import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_event.dart';
import 'package:fclub/feature/kurbani/presentation/provider/kurbani_provider.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/overview/kurbani_event_member_tile.dart';
import 'package:fclub/feature/kurbani/presentation/widgets/shared/kurbani_palette.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class KurbaniEventSetupSheet extends StatefulWidget {
  const KurbaniEventSetupSheet({super.key});

  @override
  State<KurbaniEventSetupSheet> createState() => _KurbaniEventSetupSheetState();
}

class _KurbaniEventSetupSheetState extends State<KurbaniEventSetupSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contributionController = TextEditingController();
  final Set<String> _selectedIds = {};
  String _query = '';
  bool _didSetDefaultName = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<KurbaniProvider>();
      final userId = provider.currentUserId;
      if (userId != null) _selectedIds.add(userId);
      provider.loadGroupMembers();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didSetDefaultName) return;
    final displayYear = NumberFormat.decimalPattern(
      context.locale.toString(),
    ).format(DateTime.now().year);
    _nameController.text = context.tr(
      'kurbani_default_event_name',
      namedArgs: {'year': displayYear},
    );
    _didSetDefaultName = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contributionController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedIds.isEmpty) {
      _showError('kurbani_error_participants_required');
      return;
    }
    final amount = double.tryParse(_contributionController.text.trim()) ?? 0;
    try {
      final event = await context.read<KurbaniProvider>().createEvent(
        name: _nameController.text,
        participantIds: _selectedIds,
        contribution: amount,
      );
      if (mounted) Navigator.pop<KurbaniEvent>(context, event);
    } catch (_) {
      if (!mounted) return;
      _showError(
        context.read<KurbaniProvider>().actionError ?? 'kurbani_error_unknown',
      );
    }
  }

  void _showError(String key) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(key.tr())));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KurbaniProvider>();
    final colors = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final query = _query.trim().toLowerCase();
    final members = provider.groupMembers
        .where(
          (member) =>
              query.isEmpty ||
              member.username.toLowerCase().contains(query) ||
              member.email.toLowerCase().contains(query),
        )
        .toList(growable: false);

    return DraggableScrollableSheet(
      initialChildSize: .92,
      minChildSize: .65,
      maxChildSize: .96,
      expand: false,
      snap: true,
      snapSizes: const [.65, .92],
      builder: (context, scrollController) => AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(
                color: KurbaniPalette.gold.withValues(alpha: .35),
              ),
            ),
          ),
          child: Form(
            key: _formKey,
            child: CustomScrollView(
              controller: scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                  sliver: SliverList.list(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'kurbani_event_name'.tr(),
                          prefixIcon: const Icon(Icons.auto_awesome_rounded),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'kurbani_event_name_required'.tr()
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _contributionController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'kurbani_planned_contribution'.tr(),
                          prefixIcon: const Icon(Icons.savings_rounded),
                          prefixText: '৳ ',
                        ),
                        validator: (value) =>
                            (double.tryParse(value?.trim() ?? '') ?? 0) <= 0
                            ? 'kurbani_contribution_required'.tr()
                            : null,
                      ),
                      const SizedBox(height: 19),
                      Row(
                        children: [
                          Text(
                            'kurbani_choose_participants'.tr(),
                            style: const TextStyle(
                              fontFamily: MyString.poppinsBold,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'kurbani_selected_count'.tr(
                              namedArgs: {'count': '${_selectedIds.length}'},
                            ),
                            style: const TextStyle(
                              color: KurbaniPalette.emerald,
                              fontFamily: MyString.rubikMedium,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      TextField(
                        onChanged: (value) => setState(() => _query = value),
                        decoration: InputDecoration(
                          hintText: 'kurbani_search_members'.tr(),
                          prefixIcon: const Icon(Icons.search_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (provider.isLoadingMembers)
                        const Padding(
                          padding: EdgeInsets.all(30),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (provider.actionError != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Column(
                            children: [
                              Text(
                                provider.actionError!.tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colors.error,
                                  fontFamily: MyString.rubikRegular,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: provider.loadGroupMembers,
                                icon: const Icon(Icons.refresh_rounded),
                                label: Text('group_retry'.tr()),
                              ),
                            ],
                          ),
                        )
                      else if (members.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'kurbani_no_group_members'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontFamily: MyString.rubikRegular,
                            ),
                          ),
                        )
                      else
                        ...members.map(
                          (member) => KurbaniEventMemberTile(
                            member: member,
                            selected: _selectedIds.contains(member.id),
                            onChanged: (selected) => setState(() {
                              if (selected) {
                                _selectedIds.add(member.id);
                              } else {
                                _selectedIds.remove(member.id);
                              }
                            }),
                          ),
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: provider.isSubmitting ? null : _create,
                          style: FilledButton.styleFrom(
                            backgroundColor: KurbaniPalette.emerald,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          icon: provider.isSubmitting
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.rocket_launch_rounded),
                          label: Text('kurbani_create_event'.tr()),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 10, 14, 18),
    decoration: const BoxDecoration(gradient: KurbaniPalette.heroGradient),
    child: Column(
      children: [
        Container(
          width: 46,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .32),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.nightlight_round,
                color: KurbaniPalette.gold,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'kurbani_new_event_kicker'.tr(),
                    style: const TextStyle(
                      color: KurbaniPalette.gold,
                      fontFamily: MyString.rubikMedium,
                      fontSize: 9,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'kurbani_new_event_title'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: MyString.poppinsBold,
                      fontSize: 19,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded, color: Colors.white70),
            ),
          ],
        ),
      ],
    ),
  );
}
