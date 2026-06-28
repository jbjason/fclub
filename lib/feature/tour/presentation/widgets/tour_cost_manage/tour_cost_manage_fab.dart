import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_cost_manage/tour_speed_dial_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Speed-dial FAB for [TourCostManageScreen]. Owns its own open/close state
/// and animates a breathing glow ring around the main button while closed,
/// drawing the eye without requiring user interaction.
class TourCostManageFab extends StatefulWidget {
  const TourCostManageFab({
    super.key,
    required this.onAddExpense,
    required this.onAddExtraPayment,
  });

  final VoidCallback onAddExpense;
  final VoidCallback onAddExtraPayment;

  @override
  State<TourCostManageFab> createState() => _TourCostManageFabState();
}

class _TourCostManageFabState extends State<TourCostManageFab>
    with TickerProviderStateMixin {
  bool _isOpen = false;

  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  late final AnimationController _rotateController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) {
      _rotateController.forward();
    } else {
      _rotateController.reverse();
    }
  }

  void _close() {
    if (!_isOpen) return;
    setState(() => _isOpen = false);
    _rotateController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TourSpeedDialOption(
          label: 'Add Extra Payment',
          icon: Icons.payments_rounded,
          isVisible: _isOpen,
          accentColor: MyColor.tertiary,
          animationDelay: const Duration(milliseconds: 40),
          onTap: () {
            _close();
            widget.onAddExtraPayment();
          },
        ),
        SizedBox(height: 12.h),
        TourSpeedDialOption(
          label: 'Add Expense',
          icon: Icons.receipt_long_rounded,
          isVisible: _isOpen,
          accentColor: MyColor.secondary,
          onTap: () {
            _close();
            widget.onAddExpense();
          },
        ),
        SizedBox(height: 16.h),
        _MainDialButton(
          isOpen: _isOpen,
          pulseController: _pulseController,
          rotateController: _rotateController,
          onTap: _toggle,
        ),
      ],
    );
  }
}

class _MainDialButton extends StatelessWidget {
  const _MainDialButton({
    required this.isOpen,
    required this.pulseController,
    required this.rotateController,
    required this.onTap,
  });

  final bool isOpen;
  final AnimationController pulseController;
  final AnimationController rotateController;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76.r,
      height: 76.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Breathing glow rings — only animate while the dial is closed.
          AnimatedBuilder(
            animation: pulseController,
            builder: (_, _) {
              final t = isOpen ? 0.0 : pulseController.value;
              return Container(
                width: 56.r + (20.r * t),
                height: 56.r + (20.r * t),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      MyColor.primary.withValues(alpha: 0.18 * (1 - t)),
                      MyColor.primary.withValues(alpha: 0),
                    ],
                  ),
                ),
              );
            },
          ),
          GestureDetector(
            onTap: onTap,
            child: AnimatedBuilder(
              animation: rotateController,
              builder: (_, _) {
                final t = rotateController.value;
                return Transform.rotate(
                  angle: t * 0.5 * 3.14159,
                  child: Container(
                    width: 56.r,
                    height: 56.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          MyColor.primary,
                          MyColor.secondary,
                          MyColor.tertiary,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: MyColor.primary.withValues(alpha: 0.4),
                          blurRadius: 16.r,
                          offset: Offset(0, 6.h),
                        ),
                      ],
                    ),
                    child: Icon(
                      isOpen ? Icons.close_rounded : Icons.add_rounded,
                      color: MyColor.white,
                      size: 26.r,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
