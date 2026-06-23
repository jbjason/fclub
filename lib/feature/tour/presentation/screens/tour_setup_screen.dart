import 'package:fclub/config/router/app_router.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/my_dialog.dart';
import 'package:fclub/feature/tour/presentation/provider/tour_provider.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TourSetupScreen extends StatefulWidget {
  const TourSetupScreen({super.key});

  @override
  State<TourSetupScreen> createState() => _TourSetupScreenState();
}

class _TourSetupScreenState extends State<TourSetupScreen> {
  final _tourNameController = TextEditingController();
  final _budgetController = TextEditingController();
  final _memberNameController = TextEditingController();
  final List<String> _memberNames = [];

  @override
  void dispose() {
    _tourNameController.dispose();
    _budgetController.dispose();
    _memberNameController.dispose();
    super.dispose();
  }

  void _addMember() {
    final name = _memberNameController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _memberNames.add(name);
      _memberNameController.clear();
    });
  }

  void _removeMember(int index) {
    setState(() => _memberNames.removeAt(index));
  }

  Future<void> _startTour() async {
    final tourName = _tourNameController.text.trim();
    final budget = double.tryParse(_budgetController.text.trim()) ?? 0;

    if (tourName.isEmpty) {
      MyDialog().showFailedToast(msg: 'Enter a tour name.', context: context);
      return;
    }
    if (budget <= 0) {
      MyDialog().showFailedToast(
        msg: 'Enter a valid decided budget.',
        context: context,
      );
      return;
    }
    if (_memberNames.isEmpty) {
      MyDialog().showFailedToast(
        msg: 'Add at least one member.',
        context: context,
      );
      return;
    }

    await context.read<TourProvider>().setupTour(
      tourName: tourName,
      decidedBudget: budget,
      memberNames: _memberNames,
    );

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRouteName.tourCostManage);
  }

  Future<void> _loadDemoData() async {
    await context.read<TourProvider>().seedDemoData();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRouteName.tourCostManage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Tour')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tour name', style: _labelStyle),
              SizedBox(height: 8.h),
              TextField(
                controller: _tourNameController,
                decoration: const InputDecoration(hintText: 'e.g. Cox\'s Bazar Trip'),
              ),
              SizedBox(height: 20.h),
              Text('Decided budget', style: _labelStyle),
              SizedBox(height: 8.h),
              TextField(
                controller: _budgetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(hintText: 'e.g. 20000'),
              ),
              SizedBox(height: 20.h),
              Text('Members', style: _labelStyle),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _memberNameController,
                      decoration: const InputDecoration(hintText: 'Member name'),
                      onSubmitted: (_) => _addMember(),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton.filled(
                    onPressed: _addMember,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              if (_memberNames.isNotEmpty)
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: List.generate(_memberNames.length, (index) {
                    return Chip(
                      avatar: TourMemberAvatar(
                        name: _memberNames[index],
                        colorIndex: index,
                        radius: 12.r,
                      ),
                      label: Text(_memberNames[index]),
                      onDeleted: () => _removeMember(index),
                    );
                  }),
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _loadDemoData,
                  child: const Text('Try with demo data'),
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startTour,
                  child: const Text('Start Tour'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle get _labelStyle => TextStyle(
    fontFamily: MyString.poppinsMedium,
    fontWeight: FontWeight.w600,
    fontSize: 13.sp,
    color: MyColor.onSurfaceVariant,
  );
}
