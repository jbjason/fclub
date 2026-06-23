import 'package:fclub/config/router/app_router.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/tour/presentation/provider/tour_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openTour(BuildContext context) async {
    final tourProvider = context.read<TourProvider>();
    if (!tourProvider.hasActiveTour) {
      await tourProvider.seedDemoData();
    }
    if (!context.mounted) return;
    Navigator.pushNamed(context, AppRouteName.tourCostManage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.card_travel_rounded, size: 56.r, color: MyColor.primary),
              SizedBox(height: 12.h),
              Text(
                'Tour Expense Splitter',
                style: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp,
                  color: MyColor.onSurface,
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton.icon(
                onPressed: () => _openTour(context),
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('Open Tour Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
