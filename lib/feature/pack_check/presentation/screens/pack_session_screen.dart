import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../data/model/pack_session.dart';
import '../provider/pack_check_provider.dart';
import '../widgets/pack_add_item_dialog.dart';
import '../widgets/pack_checklist_tile.dart';
import '../widgets/pack_items_grid.dart';

/// Page 2 – Step-by-step session flow (Select Items → Verify Return).
///
/// Must be reached via [PackHistoryScreen.goToSession] so that the
/// shared [PackCheckProvider] is available in this screen's widget tree.
class PackSessionScreen extends StatelessWidget {
  const PackSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF07071A) : const Color(0xFFF5F3FF),
      body: Stack(
        children: [
          if (isDark) const _SessionBgGlow(),
          SafeArea(
            child: Consumer<PackCheckProvider>(
              builder: (ctx, provider, _) {
                final session = provider.activeSession;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Rich app bar (includes session header + step indicator)
                    _SessionAppBar(
                      provider: provider,
                      session: session,
                      isDark: isDark,
                      onBack: provider.isCheckMode
                          ? provider.enterPackMode
                          : provider.isDraftMode
                              ? () => _confirmDiscard(ctx, provider, isDark)
                              : () => Navigator.pop(ctx),
                    ),

                    SizedBox(height: 8.h),

                    // ── Instruction banner
                    if (session != null) ...[
                      _InstructionBanner(
                          isCheckMode: provider.isCheckMode, isDark: isDark),
                      SizedBox(height: 8.h),
                    ],

                    // ── Main content area
                    Expanded(
                      child: session == null
                          ? _NoSession(isDark: isDark)
                          : provider.isCheckMode
                              ? _CheckListView(
                                  provider: provider, isDark: isDark)
                              : const PackItemsGrid(),
                    ),

                    // ── Bottom CTA
                    if (session != null)
                      _BottomCta(
                          provider: provider, ctx: ctx, isDark: isDark),
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

  Future<void> _confirmDiscard(
    BuildContext context,
    PackCheckProvider provider,
    bool isDark,
  ) async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:
            isDark ? const Color(0xFF12102A) : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Discard session?',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A0A3D),
            fontFamily: 'Poppins_Bold',
          ),
        ),
        content: Text(
          'You haven\'t confirmed this session yet.\nLeaving now will discard it completely.',
          style: TextStyle(
            color: isDark ? Colors.white54 : const Color(0xFF7B6EA0),
            fontFamily: 'Poppins_Regular',
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Keep editing',
              style: TextStyle(
                color:
                    isDark ? Colors.white54 : const Color(0xFF9E93C8),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Discard',
              style: TextStyle(
                color: Color(0xFFF43F5E),
                fontFamily: 'Poppins_Bold',
              ),
            ),
          ),
        ],
      ),
    );
    if (discard == true && context.mounted) {
      provider.discardDraft();
      Navigator.pop(context);
    }
  }
}

// ── Rich App Bar ──────────────────────────────────────────────────────────────
//
// Layout:
//   Row 1: [← back]  "Carry Check" gradient     [Step●──Step○]
//   Row 2: [📦 icon]  Session name · count       [Draft/Active pill]
//   Divider

class _SessionAppBar extends StatelessWidget {
  const _SessionAppBar({
    required this.provider,
    required this.session,
    required this.isDark,
    required this.onBack,
  });

  final PackCheckProvider provider;
  final PackSession? session;
  final bool isDark;
  final VoidCallback onBack;

  Color get _backColor {
    if (provider.isDraftMode && !provider.isCheckMode) {
      return const Color(0xFFF43F5E);
    }
    return isDark ? Colors.white70 : const Color(0xFF5B3DB5);
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? Colors.white : const Color(0xFF1A0A3D);
    final textSecondary =
        isDark ? Colors.white60 : const Color(0xFF7B6EA0);
    final dividerColor =
        isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFEDE8FF);
    final cardBg =
        isDark ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.8);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(
              bottom: BorderSide(color: dividerColor, width: 1),
            ),
          ),
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row 1: navigation + title + step pills
              Row(
                children: [
                  GestureDetector(
                    onTap: onBack,
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        color: _backColor, size: 20.r),
                  ),
                  SizedBox(width: 8.w),
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [Color(0xFFA855F7), Color(0xFF06B6D4)],
                    ).createShader(b),
                    child: Text(
                      'Carry Check',
                      style: TextStyle(
                        fontFamily: 'Poppins_Black',
                        fontSize: 18.sp,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (session != null)
                    _StepPills(
                      isCheckMode: provider.isCheckMode,
                      isDark: isDark,
                      onStepOneTap: provider.isCheckMode
                          ? provider.enterPackMode
                          : null,
                    ),
                ],
              ),

              // ── Row 2: session info (only when session exists)
              if (session != null) ...[
                SizedBox(height: 10.h),
                Row(
                  children: [
                    // Session icon
                    Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFA855F7), Color(0xFF06B6D4)],
                        ),
                      ),
                      child: Icon(Icons.backpack_rounded,
                          color: Colors.white, size: 16.r),
                    ),
                    SizedBox(width: 8.w),
                    // Name + count
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins_Bold',
                              fontSize: 13.sp,
                              color: textPrimary,
                            ),
                          ),
                          Text(
                            provider.isCheckMode
                                ? '${session!.checkedBackCount} of ${session!.packedCount} verified'
                                : '${session!.packedCount} of ${session!.items.length} selected',
                            style: TextStyle(
                              fontFamily: 'Poppins_Regular',
                              fontSize: 10.sp,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Draft / Active pill
                    _StatusPill(
                        isDraft: provider.isDraftMode, isDark: isDark),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step pills widget ─────────────────────────────────────────────────────────

class _StepPills extends StatelessWidget {
  const _StepPills({
    required this.isCheckMode,
    required this.isDark,
    this.onStepOneTap,
  });

  final bool isCheckMode;
  final bool isDark;
  final VoidCallback? onStepOneTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Pill(
          label: 'Pack',
          isActive: !isCheckMode,
          isDone: isCheckMode,
          color: const Color(0xFFA855F7),
          isDark: isDark,
          onTap: onStepOneTap,
        ),
        SizedBox(
          width: 20.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 1.5,
                color:
                    isCheckMode ? const Color(0xFF06B6D4) : Colors.grey.shade400,
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 8.r,
                color: isCheckMode
                    ? const Color(0xFF06B6D4)
                    : Colors.grey.shade400,
              ),
            ],
          ),
        ),
        _Pill(
          label: 'Check',
          isActive: isCheckMode,
          isDone: false,
          color: const Color(0xFF06B6D4),
          isDark: isDark,
          onTap: null,
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.isActive,
    required this.isDone,
    required this.color,
    required this.isDark,
    this.onTap,
  });

  final String label;
  final bool isActive;
  final bool isDone;
  final Color color;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = isActive || isDone;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: active ? color.withOpacity(0.15) : Colors.transparent,
          border: Border.all(
            color: active
                ? color.withOpacity(0.6)
                : (isDark ? Colors.white24 : const Color(0xFFD0C8F0)),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDone)
              Icon(Icons.check_rounded, size: 10.r, color: color),
            if (isDone) SizedBox(width: 2.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: active ? 'Poppins_Bold' : 'Poppins_Regular',
                fontSize: 9.sp,
                color: active
                    ? color
                    : (isDark ? Colors.white38 : const Color(0xFFB8A8DC)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status pill ───────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isDraft, required this.isDark});

  final bool isDraft;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = isDraft ? const Color(0xFFF59E0B) : const Color(0xFF10B981);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: color.withOpacity(isDark ? 0.12 : 0.1),
        border: Border.all(color: color.withOpacity(0.35), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5.r,
            height: 5.r,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          SizedBox(width: 4.w),
          Text(
            isDraft ? 'Draft' : 'Active',
            style: TextStyle(
              fontFamily: 'Poppins_Bold',
              fontSize: 9.sp,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Instruction banner ────────────────────────────────────────────────────────

class _InstructionBanner extends StatelessWidget {
  const _InstructionBanner(
      {required this.isCheckMode, required this.isDark});

  final bool isCheckMode;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final Color accentBg = isCheckMode
        ? const Color(0xFF06B6D4)
        : const Color(0xFFA855F7);
    final String heading = isCheckMode
        ? 'Check off items one by one'
        : 'Tap items you\'re bringing';
    final String subtext = isCheckMode
        ? 'Verify each item is packed — then mark it done.'
        : 'Select everything in your bag so nothing gets forgotten.';
    final IconData icon = isCheckMode
        ? Icons.playlist_add_check_rounded
        : Icons.touch_app_rounded;

    final bgColor = accentBg.withOpacity(isDark ? 0.1 : 0.08);
    final borderColor = accentBg.withOpacity(isDark ? 0.3 : 0.35);
    final textPrimary =
        isDark ? Colors.white : const Color(0xFF1A0A3D);
    final textSub =
        isDark ? Colors.white54 : const Color(0xFF7B6EA0);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: Padding(
        key: ValueKey(isCheckMode),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          padding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            color: bgColor,
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentBg.withOpacity(0.18),
                ),
                child: Icon(icon, color: accentBg, size: 16.r),
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
                        fontSize: 12.sp,
                        color: textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtext,
                      style: TextStyle(
                        fontFamily: 'Poppins_Regular',
                        fontSize: 10.sp,
                        color: textSub,
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
  const _CheckListView(
      {required this.provider, required this.isDark});

  final PackCheckProvider provider;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final session = provider.activeSession!;
    final packedItems = session.items.where((i) => i.isPacked).toList()
      ..sort((a, b) {
        if (a.isCheckedBack == b.isCheckedBack) return 0;
        return a.isCheckedBack ? 1 : -1;
      });

    final textPrimary =
        isDark ? Colors.white60 : const Color(0xFF7B6EA0);

    return Column(
      children: [
        _VerifyProgressBar(
            session: session, isDark: isDark),
        SizedBox(height: 4.h),
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            radius: const Radius.circular(8),
            child: ListView.builder(
              padding:
                  EdgeInsets.only(top: 4.h, bottom: 100.h),
              itemCount: packedItems.length,
              itemBuilder: (_, i) => PackChecklistTile(
                item: packedItems[i],
                onToggle: () =>
                    provider.toggleCheckedBack(packedItems[i].id),
              ),
            ),
          ),
        ),
        if (packedItems.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 40.h),
            child: Text(
              'No packed items to verify.\nGo back to Step 1 and select items.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins_Regular',
                fontSize: 13.sp,
                color: textPrimary,
                height: 1.5,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Verify progress bar ───────────────────────────────────────────────────────

class _VerifyProgressBar extends StatelessWidget {
  const _VerifyProgressBar(
      {required this.session, required this.isDark});

  final PackSession session;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final total = session.packedCount;
    final done = session.checkedBackCount;
    final progress = total == 0 ? 0.0 : done / total;
    final textSub =
        isDark ? Colors.white60 : const Color(0xFF7B6EA0);

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
                  color: textSub,
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
                backgroundColor: isDark
                    ? Colors.white.withOpacity(0.08)
                    : const Color(0xFFE0D9FF),
                valueColor: const AlwaysStoppedAnimation(
                    Color(0xFF06B6D4)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── No session fallback ───────────────────────────────────────────────────────

class _NoSession extends StatelessWidget {
  const _NoSession({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No active session.\nGo back and start one.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Poppins_Regular',
          fontSize: 13.sp,
          color: isDark ? Colors.white38 : const Color(0xFFB8A8DC),
          height: 1.5,
        ),
      ),
    );
  }
}

// ── Bottom CTA ────────────────────────────────────────────────────────────────

class _BottomCta extends StatelessWidget {
  const _BottomCta({
    required this.provider,
    required this.ctx,
    required this.isDark,
  });

  final PackCheckProvider provider;
  final BuildContext ctx;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final session = provider.activeSession!;

    if (!provider.isCheckMode && provider.hasPackedItems) {
      final isDraft = provider.isDraftMode;
      return _CtaBar(
        icon: isDraft
            ? Icons.save_alt_rounded
            : Icons.check_circle_outline_rounded,
        label: isDraft ? 'Confirm & Start Checking' : 'Back to Step 2',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:
            isDark ? const Color(0xFF12102A) : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          '🎉  All clear!',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A0A3D),
            fontFamily: 'Poppins_Bold',
          ),
        ),
        content: Text(
          'Everything is accounted for.\nThis session will be saved to your history.',
          style: TextStyle(
            color: isDark ? Colors.white54 : const Color(0xFF7B6EA0),
            fontFamily: 'Poppins_Regular',
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color:
                    isDark ? Colors.white38 : const Color(0xFF9E93C8),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Complete',
              style: TextStyle(
                color: Color(0xFF10B981),
                fontFamily: 'Poppins_Bold',
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.completeSession();
      // Pop back to history so the user sees the freshly completed session
      if (context.mounted) Navigator.pop(context);
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
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Poppins_Bold',
                        fontSize: 13.sp,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      sublabel,
                      style: TextStyle(
                        fontFamily: 'Poppins_Regular',
                        fontSize: 10.sp,
                        color: Colors.white70,
                      ),
                    ),
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
            colors: [Color(0xFFA855F7), Color(0xFF06B6D4)],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x44A855F7),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(Icons.add_rounded, color: Colors.white, size: 26.r),
      ),
    );
  }
}

// ── Background glow (dark mode only) ─────────────────────────────────────────

class _SessionBgGlow extends StatelessWidget {
  const _SessionBgGlow();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -80,
              child: Container(
                width: 240.r,
                height: 240.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    const Color(0xFF06B6D4).withOpacity(0.15),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              left: -60,
              child: Container(
                width: 200.r,
                height: 200.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    const Color(0xFFA855F7).withOpacity(0.13),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
