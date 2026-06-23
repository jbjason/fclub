import 'dart:async';

import 'package:fclub/core/constants/my_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A single speed-dial action. Supports a staggered entrance via
/// [animationDelay] so multiple options can pop in one after another.
class TourSpeedDialOption extends StatefulWidget {
  const TourSpeedDialOption({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isVisible,
    this.animationDelay = Duration.zero,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isVisible;
  final Duration animationDelay;

  @override
  State<TourSpeedDialOption> createState() => _TourSpeedDialOptionState();
}

class _TourSpeedDialOptionState extends State<TourSpeedDialOption> {
  bool _show = false;
  Timer? _timer;

  @override
  void didUpdateWidget(TourSpeedDialOption oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible == oldWidget.isVisible) return;
    _timer?.cancel();
    if (widget.isVisible) {
      _timer = Timer(widget.animationDelay, () {
        if (mounted) setState(() => _show = true);
      });
    } else {
      setState(() => _show = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _show ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: AnimatedScale(
        scale: _show ? 1 : 0.4,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        alignment: Alignment.bottomRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: MyColor.onSurface,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                widget.label,
                style: TextStyle(color: MyColor.white, fontSize: 12.sp),
              ),
            ),
            SizedBox(width: 10.w),
            FloatingActionButton.small(
              heroTag: widget.label,
              onPressed: widget.onTap,
              backgroundColor: MyColor.secondary,
              child: Icon(widget.icon, size: 18.r),
            ),
          ],
        ),
      ),
    );
  }
}
