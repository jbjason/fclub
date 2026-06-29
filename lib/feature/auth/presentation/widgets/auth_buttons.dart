import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/feature/auth/presentation/provider/signin_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthButtons extends StatelessWidget {
  const AuthButtons({required this.isLoading, super.key});
  final bool isLoading;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isLoading) ...[
          const CircularProgressIndicator(),
        ] else ...[
          // signIn text
          Container(
            width: double.infinity,
            height: 60,
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0,
              vertical: 10.0,
            ),
            child: ElevatedButton(
              onPressed: () => _onSubmit(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white70,
                shadowColor: Colors.black,
                backgroundColor: Colors.transparent,
                elevation: 15,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      MyColor.logGradient1Color,
                      MyColor.logGradient2Color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    'Sign In',
                    style: const TextStyle(color: Colors.white70,fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _onSubmit(BuildContext context) async {
    final provider = context.read<SignInProvider>();
    FocusScope.of(context).unfocus();
    await provider.signIn(context);
  }
}
