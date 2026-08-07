import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Compact gateway action that signs the current account out.
class GroupLogoutButton extends StatelessWidget {
  const GroupLogoutButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = isLoading ? 'signing_out'.tr() : 'sign_out'.tr();

    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        child: Material(
          color: colorScheme.errorContainer.withValues(alpha: 0.64),
          borderRadius: BorderRadius.circular(14.r),
          child: InkWell(
            key: const Key('group-gateway-logout-button'),
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(14.r),
            child: Container(
              width: 42.r,
              height: 42.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: colorScheme.error.withValues(alpha: 0.22),
                ),
              ),
              child: isLoading
                  ? SizedBox.square(
                      dimension: 18.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        color: colorScheme.error,
                      ),
                    )
                  : Icon(
                      Icons.logout_rounded,
                      color: colorScheme.error,
                      size: 20.r,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
