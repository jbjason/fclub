import 'package:flutter/material.dart';
import 'package:fclub/core/util/my_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [pdfUrl] in an external viewer/browser.
/// Shows a failure toast if the URL is invalid or can't be launched.
Future<void> openPdf(BuildContext context, String pdfUrl) async {
  final uri = Uri.tryParse(pdfUrl);
  final launched = uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication);

  if (!launched && context.mounted) {
    MyDialog().showFailedToast(msg: 'Unable to open PDF.', context: context);
  }
}
