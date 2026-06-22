import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/feature/auth/presentation/provider/signin_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.controller,
    required this.title,
    super.key,
  });
  final TextEditingController controller;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // title text
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 2),
        //  textfield
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [MyColor.logGradient1Color, MyColor.logGradient2Color],
            ),
          ),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(fontSize: 13, color: Colors.white),
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              errorStyle: TextStyle(color: Colors.white, fontSize: 11),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
            validator: (value) {
              final provider = context.read<SignInProvider>();
              if (title.toLowerCase() == 'email') {
                final emailValidate = provider.validateEmail(value);
                if (emailValidate != null) return emailValidate;
                return null;
              } else {
                final passValidate = provider.validatePassword(value);
                if (passValidate != null) return passValidate;
                return null;
              }
            },
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
