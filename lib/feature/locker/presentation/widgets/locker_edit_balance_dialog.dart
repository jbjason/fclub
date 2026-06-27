import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/locker/presentation/provider/locker_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Lets the admin set the locker's base balance — the "total collected from
/// all members" figure expenses are deducted from. Offers Club's actual
/// collected total as a one-tap suggestion when it differs.
Future<void> showLockerEditBalanceDialog(
  BuildContext context,
  LockerProvider lockerProvider,
) async {
  final controller = TextEditingController(
    text: lockerProvider.baseBalance == 0
        ? ''
        : lockerProvider.baseBalance.toStringAsFixed(0),
  );
  final suggestion = lockerProvider.clubCollectedTotal;
  final showSuggestion = suggestion > 0 && suggestion != lockerProvider.baseBalance;

  final result = await showDialog<double>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Update Total Collected'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount'),
          ),
          if (showSuggestion) ...[
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () => controller.text = suggestion.toStringAsFixed(0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: MyColor.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: MyColor.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.savings_rounded, size: 14.r, color: MyColor.primary),
                    SizedBox(width: 6.w),
                    Text(
                      'Use Fundora Club total: ${CurrencyFormatter.format(suggestion)}',
                      style: TextStyle(
                        fontFamily: MyString.poppinsMedium,
                        fontSize: 11.sp,
                        color: MyColor.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(
            dialogContext,
            double.tryParse(controller.text.trim()) ?? lockerProvider.baseBalance,
          ),
          child: const Text('Save'),
        ),
      ],
    ),
  );

  if (result != null) {
    await lockerProvider.setBaseBalance(result);
  }
}
