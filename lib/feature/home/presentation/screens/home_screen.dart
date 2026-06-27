import 'package:fclub/config/router/app_router.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openTour(BuildContext context) async {
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
              Icon(
                Icons.card_travel_rounded,
                size: 56.r,
                color: MyColor.primary,
              ),
              SizedBox(height: 12.h),
              ElevatedButton.icon(
                onPressed: (){},
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('Open '),
              ),
              SizedBox(height: 20.h),
              ElevatedButton.icon(
                onPressed: () => _openTour(context),
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('Open Tour Dashboard'),
              ),
              SizedBox(height: 20.h),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRouteName.kurbani);
                },
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('Open Kurbani'),
              ),
              SizedBox(height: 20.h),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRouteName.packCheck);
                },
                icon: const Icon(Icons.backpack_rounded),
                label: const Text('Carry Check'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
