import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/model/pack_item.dart';
import '../../data/model/pack_session.dart';
import '../provider/pack_check_provider.dart';
import '../widgets/pack_history_view.dart';
import 'pack_session_screen.dart';

/// Page 1 – Shows completed session history and lets the user start or
/// resume a session. Navigate here first; session flow lives in
/// [PackSessionScreen].
class PackHistoryScreen extends StatelessWidget {
  const PackHistoryScreen({super.key});

  // ── Navigation ────────────────────────────────────────────────────────────

  static void goToSession(BuildContext context, PackCheckProvider provider) {
    Navigator.push(
      context,
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => ChangeNotifierProvider.value(
          value: provider,
          child: const PackSessionScreen(),
        ),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }

  Future<void> _createNewSession(
    BuildContext context,
    PackCheckProvider provider,
  ) async {
    if (!provider.canCreateNew) return;
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _NewSessionDialog(controller: ctrl),
    );
    if (name != null && context.mounted) {
      provider.startDraft(name);
      goToSession(context, provider);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF07071A) : const Color(0xFFF5F3FF),
      body: Stack(
        children: [
          if (isDark) const _BackgroundGlow(),
          SafeArea(
            child: Consumer<PackCheckProvider>(
              builder: (ctx, provider, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HistoryAppBar(isDark: isDark),
                    SizedBox(height: 12.h),

                    // ── Resume card shown while a session is in progress
                    if (provider.hasActiveSession) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: _ResumeCard(
                          session: provider.activeSession!,
                          isDraft: provider.isDraftMode,
                          isDark: isDark,
                          onResume: () => goToSession(ctx, provider),
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],

                    // ── Full history list
                    Expanded(
                      child: PackHistoryView(
                        isDark: isDark,
                        onCreateNew: provider.canCreateNew
                            ? () => _createNewSession(ctx, provider)
                            : null,
                        onView: (session) =>
                            _PackSessionDetailSheet.show(context, session, isDark),
                        onDelete: (id) =>
                            _confirmDelete(ctx, provider, id, isDark),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    PackCheckProvider provider,
    String id,
    bool isDark,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:
            isDark ? const Color(0xFF12102A) : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Delete session?',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A0A3D),
            fontFamily: 'Poppins_Bold',
          ),
        ),
        content: Text(
          'This session will be permanently removed from history.',
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
                color: isDark ? Colors.white38 : const Color(0xFF9E93C8),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Color(0xFFF43F5E),
                fontFamily: 'Poppins_Bold',
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.deleteSession(id);
    }
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _HistoryAppBar extends StatelessWidget {
  const _HistoryAppBar({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white70 : const Color(0xFF5B3DB5),
            ),
          ),
          SizedBox(width: 10.w),

          // Title
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

          // Subtitle label
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: const Color(0xFFA855F7).withOpacity(isDark ? 0.12 : 0.1),
              border: Border.all(
                color: const Color(0xFFA855F7).withOpacity(isDark ? 0.3 : 0.35),
                width: 0.8,
              ),
            ),
            child: Text(
              'History',
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

// ── Resume card ───────────────────────────────────────────────────────────────

class _ResumeCard extends StatelessWidget {
  const _ResumeCard({
    required this.session,
    required this.isDraft,
    required this.isDark,
    required this.onResume,
  });

  final PackSession session;
  final bool isDraft;
  final bool isDark;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final color = isDraft ? const Color(0xFFF59E0B) : const Color(0xFFA855F7);

    return GestureDetector(
      onTap: onResume,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: color.withOpacity(isDark ? 0.08 : 0.07),
          border: Border.all(color: color.withOpacity(0.4), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.18),
              ),
              child: Icon(
                isDraft
                    ? Icons.edit_note_rounded
                    : Icons.play_circle_outline_rounded,
                color: color,
                size: 22.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins_Bold',
                      fontSize: 13.sp,
                      color: isDark ? Colors.white : const Color(0xFF1A0A3D),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isDraft
                        ? 'Draft – ${session.packedCount} items selected'
                        : '${session.packedCount} of ${session.items.length} items – tap to continue',
                    style: TextStyle(
                      fontFamily: 'Poppins_Regular',
                      fontSize: 11.sp,
                      color: isDark ? Colors.white54 : const Color(0xFF7B6EA0),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
              ),
              child: Text(
                isDraft ? 'Continue' : 'Resume',
                style: TextStyle(
                  fontFamily: 'Poppins_Bold',
                  fontSize: 11.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Session detail bottom sheet ───────────────────────────────────────────────

class _PackSessionDetailSheet extends StatelessWidget {
  const _PackSessionDetailSheet({
    required this.session,
    required this.isDark,
  });

  final PackSession session;
  final bool isDark;

  static void show(BuildContext context, PackSession session, bool isDark) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PackSessionDetailSheet(session: session, isDark: isDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    final packed =
        session.items.where((i) => i.isPacked).toList();
    final dateLabel =
        DateFormat('d MMM y  •  h:mm a').format(session.createdAt);
    final sheetBg =
        isDark ? const Color(0xFF12102A) : Colors.white;
    final textPrimary =
        isDark ? Colors.white : const Color(0xFF1A0A3D);
    final textSecondary =
        isDark ? Colors.white54 : const Color(0xFF7B6EA0);
    final cardBg =
        isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF5F3FF);
    final cardBorder =
        isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFEDE8FF);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border(
            top: BorderSide(
              color: const Color(0xFFA855F7).withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            // Handle
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : const Color(0xFFD0C8F0),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFA855F7), Color(0xFF06B6D4)],
                      ),
                    ),
                    child: Icon(Icons.backpack_rounded,
                        color: Colors.white, size: 22.r),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.name,
                          style: TextStyle(
                            fontFamily: 'Poppins_Bold',
                            fontSize: 16.sp,
                            color: textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          dateLabel,
                          style: TextStyle(
                            fontFamily: 'Poppins_Regular',
                            fontSize: 11.sp,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Completed badge
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: const Color(0xFF10B981).withOpacity(0.12),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.35),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      '${packed.length} packed',
                      style: TextStyle(
                        fontFamily: 'Poppins_Bold',
                        fontSize: 10.sp,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Divider(
              color: isDark ? Colors.white12 : const Color(0xFFEDE8FF),
              height: 1,
              indent: 20.w,
              endIndent: 20.w,
            ),
            SizedBox(height: 8.h),
            // Packed items label
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                'Packed Items',
                style: TextStyle(
                  fontFamily: 'Poppins_Bold',
                  fontSize: 12.sp,
                  color: textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            // Items grid
            Expanded(
              child: GridView.builder(
                controller: scrollCtrl,
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                  childAspectRatio: 0.82,
                ),
                itemCount: packed.isEmpty ? 1 : packed.length,
                itemBuilder: (_, i) {
                  if (packed.isEmpty) {
                    return Center(
                      child: Text(
                        'No items packed',
                        style: TextStyle(
                          color: textSecondary,
                          fontFamily: 'Poppins_Regular',
                          fontSize: 12.sp,
                        ),
                      ),
                    );
                  }
                  return _DetailItemCell(
                    item: packed[i],
                    cardBg: cardBg,
                    cardBorder: cardBorder,
                    textPrimary: textPrimary,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItemCell extends StatelessWidget {
  const _DetailItemCell({
    required this.item,
    required this.cardBg,
    required this.cardBorder,
    required this.textPrimary,
  });

  final PackItem item;
  final Color cardBg;
  final Color cardBorder;
  final Color textPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        color: cardBg,
        border: Border.all(color: cardBorder, width: 1),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFA855F7),
            Color(0xFF06B6D4),
          ],
          stops: [0, 1],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          color: cardBg,
          border: Border.all(
            color: const Color(0xFFA855F7).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              IconData(
                item.iconCodePoint,
                fontFamily: 'MaterialIcons',
              ),
              color: const Color(0xFFA855F7),
              size: 26.r,
            ),
            SizedBox(height: 6.h),
            Text(
              item.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins_Medium',
                fontSize: 9.sp,
                color: textPrimary,
                height: 1.2,
              ),
            ),
          ],
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF12102A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A0A3D);
    final hintColor = isDark ? Colors.white38 : const Color(0xFFB8A8DC);
    final fillColor = isDark
        ? Colors.white.withOpacity(0.05)
        : const Color(0xFFF5F3FF);

    return AlertDialog(
      backgroundColor: bgColor,
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
            color: Colors.white,
          ),
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
              color: hintColor,
            ),
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: 'e.g. Office trip, Weekend outing…',
              hintStyle: TextStyle(color: hintColor),
              filled: true,
              fillColor: fillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
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
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark ? Colors.white38 : const Color(0xFF9E93C8),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            final name = controller.text.trim();
            Navigator.pop(context, name.isEmpty ? 'My Trip' : name);
          },
          child: const Text(
            'Create',
            style: TextStyle(
              color: Color(0xFFA855F7),
              fontFamily: 'Poppins_Bold',
            ),
          ),
        ),
      ],
    );
  }
}

// ── Background glow (dark mode only) ─────────────────────────────────────────

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -80,
              left: -60,
              child: Container(
                width: 260.r,
                height: 260.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFA855F7).withOpacity(0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              right: -80,
              child: Container(
                width: 220.r,
                height: 220.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF06B6D4).withOpacity(0.14),
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
