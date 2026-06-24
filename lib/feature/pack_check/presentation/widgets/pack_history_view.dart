import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../provider/pack_check_provider.dart';
import 'pack_history_tile.dart';

/// Shown when no active session exists.
///
/// Displays the full history of completed sessions and a prominent
/// "Create New Session" button. This is the only entry point for
/// creating a new session — blocked as long as one is active.
class PackHistoryView extends StatelessWidget {
  const PackHistoryView({required this.onCreateNew, super.key});

  final VoidCallback onCreateNew;

  @override
  Widget build(BuildContext context) {
    return Consumer<PackCheckProvider>(
      builder: (_, provider, __) {
        final history = provider.history;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Create new button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _CreateNewButton(onTap: onCreateNew),
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
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  if (history.isNotEmpty)
                    GestureDetector(
                      onTap: () => _confirmClearHistory(context, provider),
                      child: Text(
                        'Clear all',
                        style: TextStyle(
                          fontFamily: 'Poppins_Regular',
                          fontSize: 11.sp,
                          color: Colors.white30,
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
                  ? const _EmptyHistory()
                  : Scrollbar(
                      thumbVisibility: true,
                      radius: const Radius.circular(8),
                      child: ListView.builder(
                        padding: EdgeInsets.only(bottom: 32.h),
                        itemCount: history.length,
                        itemBuilder: (_, i) =>
                            PackHistoryTile(session: history[i]),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF12102A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: const Text(
          'Clear history?',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins_Bold'),
        ),
        content: const Text(
          'All completed sessions will be permanently removed.',
          style: TextStyle(
              color: Colors.white54, fontFamily: 'Poppins_Regular', height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear',
                style: TextStyle(
                    color: Color(0xFFF43F5E),
                    fontFamily: 'Poppins_Bold')),
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
  const _CreateNewButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: const LinearGradient(
            colors: [Color(0xFFA855F7), Color(0xFF06B6D4)],
          ),
          boxShadow: [
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
            Icon(Icons.add_circle_outline_rounded,
                color: Colors.white, size: 20.r),
            SizedBox(width: 8.w),
            Text(
              'Start New Session',
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
    );
  }
}

// ── Empty history state ───────────────────────────────────────────────────────

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_rounded, size: 44.r, color: Colors.white12),
          SizedBox(height: 10.h),
          Text(
            'No past sessions yet',
            style: TextStyle(
              fontFamily: 'Poppins_Medium',
              fontSize: 13.sp,
              color: Colors.white24,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Completed sessions will appear here.',
            style: TextStyle(
              fontFamily: 'Poppins_Regular',
              fontSize: 11.sp,
              color: Colors.white24,
            ),
          ),
        ],
      ),
    );
  }
}
