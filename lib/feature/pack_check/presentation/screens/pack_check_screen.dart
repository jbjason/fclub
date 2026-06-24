import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../data/model/pack_session.dart';
import '../../data/repository/pack_check_repository.dart';
import '../provider/pack_check_provider.dart';
import '../widgets/pack_add_item_dialog.dart';
import '../widgets/pack_checklist_tile.dart';
import '../widgets/pack_history_view.dart';
import '../widgets/pack_items_grid.dart';
import '../widgets/pack_session_header.dart';
import '../widgets/pack_step_indicator.dart';


class PackCheckScreen extends StatelessWidget {
  const PackCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PackCheckProvider(PackCheckRepository()),
      child: const _PackCheckView(),
    );
  }
}

class _PackCheckView extends StatelessWidget {
  const _PackCheckView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07071A),
      body: Stack(
        children: [
          const _BackgroundGlow(),
          SafeArea(
            child: Consumer<PackCheckProvider>(
              builder: (ctx, provider, _) {
                final session = provider.activeSession;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── App bar
                    _AppBar(
                      isCheckMode: provider.isCheckMode,
                      isDraftMode: provider.isDraftMode,
                      hasActiveSession: provider.hasActiveSession,
                      onBack: provider.isCheckMode
                          ? provider.enterPackMode
                          : provider.isDraftMode
                              ? () => _confirmDiscard(ctx, provider)
                              : () => Navigator.pop(ctx),
                    ),
                    SizedBox(height: 12.h),

                    // ── Active session UI
                    if (session != null) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: PackSessionHeader(session: session, isDraft: provider.isDraftMode),
                      ),
                      SizedBox(height: 10.h),
                      PackStepIndicator(
                        isCheckMode: provider.isCheckMode,
                        onStepOneTap: provider.enterPackMode,
                      ),
                      SizedBox(height: 10.h),
                      _InstructionBanner(isCheckMode: provider.isCheckMode),
                      SizedBox(height: 8.h),
                    ],

                    // ── Main content area
                    Expanded(
                      child: session == null
                          ? PackHistoryView(
                              onCreateNew: () =>
                                  _showNewSessionDialog(ctx, provider),
                            )
                          : provider.isCheckMode
                              ? _CheckListView(provider: provider)
                              : const PackItemsGrid(),
                    ),

                    // ── Bottom CTA (only when session is active)
                    if (session != null)
                      _BottomCta(provider: provider, context: ctx),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<PackCheckProvider>(
        builder: (ctx, provider, _) {
          if (!provider.hasActiveSession || provider.isCheckMode) {
            return const SizedBox.shrink();
          }
          return _AddItemFab(onTap: () => PackAddItemDialog.show(ctx));
        },
      ),
    );
  }

  Future<void> _showNewSessionDialog(
    BuildContext context,
    PackCheckProvider provider,
  ) async {
    if (!provider.canCreateNew) return;
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _NewSessionDialog(controller: ctrl),
    );
    if (name != null) {
      provider.startDraft(name);
    }
  }

  Future<void> _confirmDiscard(
    BuildContext context,
    PackCheckProvider provider,
  ) async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF12102A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Discard session?',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins_Bold'),
        ),
        content: const Text(
          'You haven\'t confirmed this session yet.\nLeaving now will discard it completely.',
          style: TextStyle(
            color: Colors.white54,
            fontFamily: 'Poppins_Regular',
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard',
                style: TextStyle(
                    color: Color(0xFFF43F5E),
                    fontFamily: 'Poppins_Bold')),
          ),
        ],
      ),
    );
    if (discard == true) {
      provider.discardDraft();
    }
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  const _AppBar({
    required this.isCheckMode,
    required this.isDraftMode,
    required this.hasActiveSession,
    required this.onBack,
  });

  final bool isCheckMode;
  final bool isDraftMode;
  final bool hasActiveSession;
  final VoidCallback onBack;

  String get _backLabel {
    if (isCheckMode) return 'Step 1';
    if (isDraftMode) return 'Discard';
    return 'Back';
  }

  Color get _backColor {
    if (isDraftMode && !isCheckMode) return const Color(0xFFF43F5E);
    return Colors.white70;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: Colors.white.withOpacity(0.07),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_ios_new_rounded,
                      color: _backColor, size: 13.r),
                  SizedBox(width: 4.w),
                  Text(
                    _backLabel,
                    style: TextStyle(
                      fontFamily: 'Poppins_Medium',
                      fontSize: 12.sp,
                      color: _backColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 10.w),
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [Color(0xFFA855F7), Color(0xFF06B6D4)],
            ).createShader(b),
            child: Text(
              'Carry Check',
              style: TextStyle(
                fontFamily: 'Poppins_Black',
                fontSize: 20.sp,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const Spacer(),
          // Show "In Progress" badge when a session is active
          if (hasActiveSession)
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: const Color(0xFFA855F7).withOpacity(0.12),
              ),
              child: Text(
                'In Progress',
                style: TextStyle(
                  fontFamily: 'Poppins_Medium',
                  fontSize: 10.sp,
                  color: const Color(0xFFA855F7),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Instruction banner ────────────────────────────────────────────────────────

class _InstructionBanner extends StatelessWidget {
  const _InstructionBanner({required this.isCheckMode});

  final bool isCheckMode;

  @override
  Widget build(BuildContext context) {
    final Color bg = isCheckMode
        ? const Color(0xFF06B6D4).withOpacity(0.1)
        : const Color(0xFFA855F7).withOpacity(0.1);
    final Color border = isCheckMode
        ? const Color(0xFF06B6D4).withOpacity(0.3)
        : const Color(0xFFA855F7).withOpacity(0.3);
    final Color iconBg =
        isCheckMode ? const Color(0xFF06B6D4) : const Color(0xFFA855F7);
    final String heading = isCheckMode
        ? 'Check off items one by one'
        : 'Tap items you\'re bringing';
    final String subtext = isCheckMode
        ? 'Verify each item is packed — then mark it done.'
        : 'Select everything in your bag so nothing gets forgotten.';
    final IconData icon = isCheckMode
        ? Icons.playlist_add_check_rounded
        : Icons.touch_app_rounded;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: Padding(
        key: ValueKey(isCheckMode),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          padding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            color: bg,
            border: Border.all(color: border, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBg.withOpacity(0.2),
                ),
                child: Icon(icon, color: iconBg, size: 18.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      heading,
                      style: TextStyle(
                        fontFamily: 'Poppins_Bold',
                        fontSize: 13.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtext,
                      style: TextStyle(
                        fontFamily: 'Poppins_Regular',
                        fontSize: 11.sp,
                        color: Colors.white54,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Check list view ───────────────────────────────────────────────────────────

class _CheckListView extends StatelessWidget {
  const _CheckListView({required this.provider});

  final PackCheckProvider provider;

  @override
  Widget build(BuildContext context) {
    final session = provider.activeSession!;
    final packedItems = session.items.where((i) => i.isPacked).toList()
      // Unchecked items first, verified at the bottom
      ..sort((a, b) {
        if (a.isCheckedBack == b.isCheckedBack) return 0;
        return a.isCheckedBack ? 1 : -1;
      });

    return Column(
      children: [
        _VerifyProgressBar(session: session),
        SizedBox(height: 4.h),
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            radius: const Radius.circular(8),
            child: ListView.builder(
              padding: EdgeInsets.only(top: 4.h, bottom: 100.h),
              itemCount: packedItems.length,
              itemBuilder: (_, i) => PackChecklistTile(
                item: packedItems[i],
                onToggle: () =>
                    provider.toggleCheckedBack(packedItems[i].id),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VerifyProgressBar extends StatelessWidget {
  const _VerifyProgressBar({required this.session});

  final PackSession session;

  @override
  Widget build(BuildContext context) {
    final total = session.packedCount;
    final done = session.checkedBackCount;
    final progress = total == 0 ? 0.0 : done / total;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$done of $total items verified',
                style: TextStyle(
                  fontFamily: 'Poppins_Medium',
                  fontSize: 12.sp,
                  color: Colors.white60,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontFamily: 'Poppins_Bold',
                  fontSize: 12.sp,
                  color: const Color(0xFF06B6D4),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 6.h,
                backgroundColor: Colors.white.withOpacity(0.08),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF06B6D4)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom CTA ────────────────────────────────────────────────────────────────

class _BottomCta extends StatelessWidget {
  const _BottomCta({required this.provider, required this.context});

  final PackCheckProvider provider;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    final session = provider.activeSession!;

    if (!provider.isCheckMode && provider.hasPackedItems) {
      // Draft: "Confirm & Start" saves for the first time.
      // Saved session going back to Step 1: "Go to Step 2" just switches mode.
      final isDraft = provider.isDraftMode;
      return _CtaBar(
        icon: isDraft
            ? Icons.save_alt_rounded
            : Icons.check_circle_outline_rounded,
        label: isDraft
            ? 'Confirm & Start Checking'
            : 'Back to Step 2',
        sublabel: isDraft
            ? '${session.packedCount} items selected — tap to save & verify'
            : '${session.packedCount} items to verify',
        gradient: const [Color(0xFFA855F7), Color(0xFF7C3AED)],
        onTap: isDraft ? provider.confirmDraft : provider.enterCheckMode,
      );
    }

    if (provider.isCheckMode && session.allCheckedBack) {
      return _CtaBar(
        icon: Icons.verified_rounded,
        label: 'All here! Mark complete',
        sublabel: 'Session will move to history',
        gradient: const [Color(0xFF10B981), Color(0xFF059669)],
        onTap: () => _onComplete(ctx, provider),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _onComplete(
    BuildContext context,
    PackCheckProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF12102A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: const Text(
          '🎉  All clear!',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins_Bold'),
        ),
        content: const Text(
          'Everything is accounted for.\nThis session will be saved to your history.',
          style: TextStyle(
            color: Colors.white54,
            fontFamily: 'Poppins_Regular',
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Complete',
              style: TextStyle(
                  color: Color(0xFF10B981), fontFamily: 'Poppins_Bold'),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.completeSession();
    }
  }
}

class _CtaBar extends StatelessWidget {
  const _CtaBar({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 62.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(colors: gradient),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withOpacity(0.38),
                blurRadius: 18,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(width: 16.w),
              Icon(icon, color: Colors.white, size: 22.r),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            fontFamily: 'Poppins_Bold',
                            fontSize: 13.sp,
                            color: Colors.white)),
                    Text(sublabel,
                        style: TextStyle(
                            fontFamily: 'Poppins_Regular',
                            fontSize: 10.sp,
                            color: Colors.white70)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white60, size: 14.r),
              SizedBox(width: 14.w),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Add item FAB ──────────────────────────────────────────────────────────────

class _AddItemFab extends StatelessWidget {
  const _AddItemFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52.r,
        height: 52.r,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
              colors: [Color(0xFFA855F7), Color(0xFF06B6D4)]),
          boxShadow: [
            BoxShadow(
                color: Color(0x44A855F7),
                blurRadius: 14,
                offset: Offset(0, 4)),
          ],
        ),
        child: Icon(Icons.add_rounded, color: Colors.white, size: 26.r),
      ),
    );
  }
}

// ── New session dialog ────────────────────────────────────────────────────────

class _NewSessionDialog extends StatelessWidget {
  const _NewSessionDialog({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF12102A),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      title: ShaderMask(
        shaderCallback: (b) => const LinearGradient(
          colors: [Color(0xFFA855F7), Color(0xFF06B6D4)],
        ).createShader(b),
        child: Text(
          'New Session',
          style: TextStyle(
              fontFamily: 'Poppins_Bold',
              fontSize: 18.sp,
              color: Colors.white),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where are you heading?',
            style: TextStyle(
                fontFamily: 'Poppins_Regular',
                fontSize: 12.sp,
                color: Colors.white38),
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'e.g. Office trip, Weekend outing…',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(
                    color: Color(0xFFA855F7), width: 1.5),
              ),
            ),
            onSubmitted: (v) => Navigator.pop(
                context, v.trim().isEmpty ? 'My Trip' : v.trim()),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel',
              style: TextStyle(color: Colors.white38)),
        ),
        TextButton(
          onPressed: () {
            final name = controller.text.trim();
            Navigator.pop(context, name.isEmpty ? 'My Trip' : name);
          },
          child: const Text('Create',
              style: TextStyle(
                  color: Color(0xFFA855F7), fontFamily: 'Poppins_Bold')),
        ),
      ],
    );
  }
}

// ── Background glow ───────────────────────────────────────────────────────────

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFA855F7).withOpacity(0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -60,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF06B6D4).withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
