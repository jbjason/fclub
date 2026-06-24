import 'package:flutter/material.dart';

class SignInTextStyle extends StatelessWidget {
  const SignInTextStyle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Padding(
          padding: EdgeInsets.only( bottom: 10),
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
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only( left: 10.0, bottom: 10),
            child: Column(
              children: [
                Container(height: 60),
                const Center(
                  child: Text(
                    'A world of possibility in an app',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
