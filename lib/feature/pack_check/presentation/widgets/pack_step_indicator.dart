import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Visualises the two-step carry-check journey so users always know
/// exactly where they are and what comes next.
///
/// - Step 1 (Select Items): tap catalog items to mark what you're bringing.
/// - Step 2 (Verify Return): tick off every item before leaving.
class PackStepIndicator extends StatelessWidget {
  const PackStepIndicator({
    required this.isCheckMode,
    required this.onStepOneTap,
    super.key,
  });

  /// True when the user is on Step 2 (verify return).
  final bool isCheckMode;

  /// Callback that lets the user navigate back to Step 1.
  final VoidCallback onStepOneTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: const Color(0xFF0D0B22),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 1),
      ),
      child: Row(
        children: [
          // Step 1
          _StepNode(
            number: 1,
            label: 'Select Items',
            sublabel: 'Tap what you\'re bringing',
            isActive: !isCheckMode,
            isCompleted: isCheckMode,
            onTap: isCheckMode ? onStepOneTap : null,
          ),
          // Connector line
          Expanded(child: _ConnectorLine(isCompleted: isCheckMode)),
          // Step 2
          _StepNode(
            number: 2,
            label: 'Verify Return',
            sublabel: 'Check off each item',
            isActive: isCheckMode,
            isCompleted: false,
            onTap: null,
          ),
        ],
      ),
    );
  }
}

// ── Step node ─────────────────────────────────────────────────────────────────

class _StepNode extends StatelessWidget {
  const _StepNode({
    required this.number,
    required this.label,
    required this.sublabel,
    required this.isActive,
    required this.isCompleted,
    this.onTap,
  });

  final int number;
  final String label;
  final String sublabel;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent =
        number == 1 ? const Color(0xFFA855F7) : const Color(0xFF06B6D4);
    final Color inactive = Colors.white24;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circle indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: 30.r,
            height: 30.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: (isActive || isCompleted)
                  ? LinearGradient(
                      colors: number == 1
                          ? [const Color(0xFFA855F7), const Color(0xFF7C3AED)]
                          : [const Color(0xFF06B6D4), const Color(0xFF0891B2)],
                    )
                  : null,
              color: (isActive || isCompleted) ? null : const Color(0xFF1E1C35),
              border: Border.all(
                color: (isActive || isCompleted) ? Colors.transparent : inactive,
                width: 1.5,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: accent.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: isCompleted
                  ? Icon(Icons.check_rounded, color: Colors.white, size: 15.r)
                  : Text(
                      '$number',
                      style: TextStyle(
                        fontFamily: 'Poppins_Bold',
                        fontSize: 12.sp,
                        color: (isActive || isCompleted) ? Colors.white : Colors.white38,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 8.w),
          // Labels
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontFamily: 'Poppins_Bold',
                  fontSize: 12.sp,
                  color: isActive ? Colors.white : (isCompleted ? accent : Colors.white38),
                ),
                child: Text(label),
              ),
              Text(
                sublabel,
                style: TextStyle(
                  fontFamily: 'Poppins_Regular',
                  fontSize: 9.5.sp,
                  color: isActive ? Colors.white54 : Colors.white24,
                ),
              ),
              // "Tap to go back" hint on Step 1 when it's completed
              if (isCompleted && onTap != null)
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_rounded, size: 9.r, color: accent),
                      SizedBox(width: 2.w),
                      Text(
                        'tap to re-select',
                        style: TextStyle(
                          fontFamily: 'Poppins_Regular',
                          fontSize: 9.sp,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Connecting line ───────────────────────────────────────────────────────────

class _ConnectorLine extends StatelessWidget {
  const _ConnectorLine({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base line
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1C35),
              borderRadius: BorderRadius.circular(1.r),
            ),
          ),
          // Progress fill
          AnimatedAlign(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: isCompleted ? 1.0 : 0.0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1.r),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA855F7), Color(0xFF06B6D4)],
                  ),
                ),
              ),
            ),
          ),
          // Arrow chevron
          Icon(
            Icons.chevron_right_rounded,
            color: isCompleted
                ? const Color(0xFF06B6D4)
                : Colors.white12,
            size: 18.r,
          ),
        ],
      ),
    );
  }
}
