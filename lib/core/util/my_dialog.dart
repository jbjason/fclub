// ignore_for_file: use_build_context_synchronously
import 'package:easy_localization/easy_localization.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:elegant_notification/resources/stacked_options.dart';
import 'package:flutter/material.dart';

class MyDialog {
  void showSuccessToast({
    required String msg,
    String? title,
    required BuildContext context,
  }) {
    ElegantNotification.success(
      isDismissable: false,
      position: Alignment.topCenter,
      width: MediaQuery.of(context).size.width - 32,
      toastDuration: const Duration(milliseconds: 2300),
      animation: AnimationType.fromTop,
      title: Text(
        title ?? 'toast_success'.tr(),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
      ),
      description: Text(
        msg,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyLarge!,
      ),
      shadow: BoxShadow(
        color: Colors.green.withValues(alpha: 0.2),
        spreadRadius: 2,
        blurRadius: 5,
        offset: const Offset(0, 4),
      ),
    ).show(context);
  }

  void showInfoToast({
    required String msg,
    String? title,
    required BuildContext context,
  }) {
    ElegantNotification.info(
      isDismissable: false,
      position: Alignment.topCenter,
      width: MediaQuery.of(context).size.width - 32,
      toastDuration: const Duration(milliseconds: 2300),
      animation: AnimationType.fromTop,
      title: Text(
        title ?? 'toast_info'.tr(),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
      ),
      description: Text(
        msg,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyLarge!,
      ),
      shadow: BoxShadow(
        color: Color(0xFF01204E).withValues(alpha: 0.2),
        spreadRadius: 2,
        blurRadius: 5,
        offset: const Offset(0, 4),
      ),
    ).show(context);
  }

  Future<void> showComingSoonDialog({
    required BuildContext context,
    String? featureName,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('coming_soon'.tr()),
        content: Text(
          featureName == null
              ? 'coming_soon_generic'.tr()
              : 'coming_soon_feature'.tr(namedArgs: {'feature': featureName}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('ok'.tr()),
          ),
        ],
      ),
    );
  }

  void showFailedToast({
    required String msg,
    String? title,
    required BuildContext context,
  }) {
    ElegantNotification.error(
      stackedOptions: StackedOptions(
        key: 'topRight',
        type: StackedType.below,
        itemOffset: const Offset(0, 5),
      ),
      position: Alignment.topRight,
      width: MediaQuery.of(context).size.width * 0.8,
      toastDuration: const Duration(milliseconds: 2300),
      animation: AnimationType.fromRight,
      title: Text(
        title ?? 'toast_failed'.tr(),
        style: Theme.of(
          context,
        ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
      ),
      description: Text(
        msg,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyLarge!,
      ),
    ).show(context);
  }
}
