import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_history/tour_field_label.dart';
import 'package:fclub/feature/tour/presentation/widgets/tour_history/tour_input_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourNewTourStepOne extends StatelessWidget {
  const TourNewTourStepOne({
    super.key,
    required this.formKey,
    required this.tourNameCtrl,
    required this.budgetCtrl,
    required this.onNext,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController tourNameCtrl;
  final TextEditingController budgetCtrl;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TourFieldLabel('Trip name'),
            SizedBox(height: 6.h),
            TextFormField(
              controller: tourNameCtrl,
              style: TextStyle(
                  fontFamily: MyString.poppinsRegular, fontSize: 14.sp),
              decoration: tourInputDecoration(
                  context,
                  hint: "e.g. Cox's Bazar Trip",
                  icon: Icons.card_travel_rounded),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            SizedBox(height: 16.h),
            const TourFieldLabel('Decided budget (৳)'),
            SizedBox(height: 6.h),
            TextFormField(
              controller: budgetCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(
                  fontFamily: MyString.poppinsRegular, fontSize: 14.sp),
              decoration: tourInputDecoration(
                  context,
                  hint: '20000', icon: Icons.savings_rounded),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (double.tryParse(v.trim()) == null) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColor.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r)),
                ),
                child: Text('Next: Add Members',
                    style: TextStyle(
                        fontFamily: MyString.poppinsBold,
                        fontSize: 14.sp)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
