import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SignInTextStyle extends StatelessWidget {
  const SignInTextStyle({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 30, left: 10, bottom: 10),
          child: RotatedBox(
            quarterTurns: -1,
            child: Text(
              'sign_in'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Text(
              'auth_tagline'.tr(),
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
