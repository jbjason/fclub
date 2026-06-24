import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../data/model/pack_session.dart';
import '../provider/pack_check_provider.dart';
import 'pack_history_tile.dart';

/// Full history list widget.
///
/// - [onCreateNew] is null when an active session already exists (button is
///   shown but disabled with a visual indicator).
/// - [onView] is called with the tapped session to open a detail sheet.
/// - [onDelete] is called with the session id to trigger a confirmation.
class PackHistoryView extends StatelessWidget {
  const PackHistoryView({
    required this.isDark,
    this.onCreateNew,
    this.onView,
    this.onDelete,
    super.key,
  });

  final bool isDark;
  final VoidCallback? onCreateNew;
  final void Function(PackSession)? onView;
  final void Function(String id)? onDelete;

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? Colors.white : const Color(0xFF1A0A3D);
    final textHint =
        isDark ? Colors.white30 : const Color(0xFFB8A8DC);

    return Consumer<PackCheckProvider>(
      builder: (_, provider, __) {
        final history = provider.history;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Create new button
            if (onCreateNew != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _CreateNewButton(onTap: onCreateNew!, isDark: isDark),
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _CreateNewButton(
                  onTap: () {},
                  isDark: isDark,
                  disabled: true,
                ),
              ),
            SizedBox(height: 20.h),

            // ── History heading
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Text(
                    'Past Sessions',
                    style: TextStyle(
                      fontFamily: 'Poppins_Bold',
                      fontSize: 14.sp,
                      color: textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (history.isNotEmpty)
                    GestureDetector(
                      onTap: () =>
                          _confirmClearHistory(context, provider),
                      child: Text(
                        'Clear all',
                        style: TextStyle(
                          fontFamily: 'Poppins_Regular',
                          fontSize: 11.sp,
                          color: textHint,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 8.h),

            // ── List or empty state
            Expanded(
              child: history.isEmpty
                  ? _EmptyHistory(isDark: isDark)
                  : Scrollbar(
                      thumbVisibility: true,
                      radius: const Radius.circular(8),
                      child: ListView.builder(
                        padding: EdgeInsets.only(bottom: 32.h),
                        itemCount: history.length,
                        itemBuilder: (_, i) => PackHistoryTile(
                          session: history[i],
                          isDark: isDark,
                          onView: onView != null
                              ? () => onView!(history[i])
                              : null,
                          onDelete: onDelete != null
                              ? () => onDelete!(history[i].id)
                              : null,
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmClearHistory(
    BuildContext context,
    PackCheckProvider provider,
  ) async {
    final bgColor =
        isDark ? const Color(0xFF12102A) : Colors.white;
    final textColor =
        isDark ? Colors.white : const Color(0xFF1A0A3D);
    final subColor =
        isDark ? Colors.white54 : const Color(0xFF7B6EA0);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Clear history?',
          style: TextStyle(
              color: textColor, fontFamily: 'Poppins_Bold'),
        ),
        content: Text(
          'All completed sessions will be permanently removed.',
          style: TextStyle(
              color: subColor,
              fontFamily: 'Poppins_Regular',
              height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? Colors.white38
                    : const Color(0xFF9E93C8),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Clear',
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
      await provider.clearHistory();
    }
  }
}

// ── Create new button ─────────────────────────────────────────────────────────

class _CreateNewButton extends StatelessWidget {
  const _CreateNewButton({
    required this.onTap,
    required this.isDark,
    this.disabled = false,
  });

  final VoidCallback onTap;
  final bool isDark;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Opacity(
        opacity: disabled ? 0.4 : 1.0,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: const LinearGradient(
              colors: [Color(0xFFA855F7), Color(0xFF06B6D4)],
            ),
            boxShadow: disabled
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFFA855F7).withOpacity(0.38),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                disabled
                    ? Icons.lock_outline_rounded
                    : Icons.add_circle_outline_rounded,
                color: Colors.white,
                size: 20.r,
              ),
              SizedBox(width: 8.w),
              Text(
                disabled
                    ? 'Finish active session first'
                    : 'Start New Session',
                style: TextStyle(
                  fontFamily: 'Poppins_Bold',
                  fontSize: 15.sp,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty history state ───────────────────────────────────────────────────────

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = isDark ? Colors.white12 : const Color(0xFFD0C8F0);
    final textColor = isDark ? Colors.white24 : const Color(0xFFB8A8DC);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_rounded, size: 44.r, color: color),
          SizedBox(height: 10.h),
          Text(
            'No past sessions yet',
            style: TextStyle(
              fontFamily: 'Poppins_Medium',
              fontSize: 13.sp,
              color: textColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Completed sessions will appear here.',
            style: TextStyle(
              fontFamily: 'Poppins_Regular',
              fontSize: 11.sp,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
