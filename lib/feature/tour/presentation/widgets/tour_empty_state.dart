import 'package:fclub/core/constants/my_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourEmptyState extends StatelessWidget {
  const TourEmptyState({super.key, required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  MyColor.primaryContainer,
                  MyColor.secondaryContainer,
                ],
              ),
            ),
            child: Icon(icon, size: 40.r, color: MyColor.primary),
          ),
          SizedBox(height: 14.h),
          Text(message, style: TextStyle(color: MyColor.outline)),
        ],
      ),
    );
  }
}
