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
          GestureDetector(
            onTap: () => _onSubmit(context),
            child: Container(
              height: 45,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    MyColor.logGradient1Color,
                    MyColor.logGradient2Color,
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  'Sign In',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white70,
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
