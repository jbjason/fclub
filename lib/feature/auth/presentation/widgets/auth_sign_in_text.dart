import 'package:flutter/material.dart';

class SignInTextStyle extends StatelessWidget {
  const SignInTextStyle({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 30, left: 10, bottom: 10),
          child: RotatedBox(
            quarterTurns: -1,
            child: Text(
              'Sign in',
              style: TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        IntrinsicHeight(
          child: const Padding(
            padding: EdgeInsets.only(top: 15),
            child: Text(
              'A world of\npossibility in an\napp',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
