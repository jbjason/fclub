import 'package:fclub/config/extension/media_query_extension.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/feature/auth/presentation/widgets/auth_body.dart';
import 'package:fclub/feature/auth/presentation/widgets/auth_clippers.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.logBackColor,
      body: Center(
        child: AnimatedContainer(
          height: context.screenHeight * .5,
          width: context.screenWidth * .8,
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [MyColor.logGradient1Color, MyColor.logGradient2Color],
            ),
          ),
          child: ClipPath(
            clipper: AuthClipper(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 35),
              decoration: BoxDecoration(
                color: MyColor.logBackColor,
                border: Border.all(color: Colors.black),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: AuhtBody(),
            ),
          ),
        ),
      ),
    );
  }
}
