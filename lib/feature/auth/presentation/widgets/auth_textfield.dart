import 'package:fclub/core/constants/my_icon.dart';
import 'package:fclub/feature/auth/presentation/provider/signin_provider.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    required this.controller,
    required this.title,
    required this.prefixIcon,
    this.isPassword = false,
    super.key,
  });
  final TextEditingController controller;
  final String title;
  final IconData prefixIcon;
  final bool isPassword;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscureText,
      decoration: InputDecoration(
        hintText: widget.title,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom:  8.0),
          child: Lottie.asset(
            widget.isPassword ? MyIcon.password : MyIcon.email,
            width: 15,
            height: 10,
            fit: BoxFit.contain,
          ),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        filled: false,
        errorStyle: TextStyle(color: Colors.white, fontSize: 11),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
        fontWeight: FontWeight.normal,
        color: Colors.white,
        fontSize: 14,
      ),
      validator: (value) {
        final provider = context.read<SignInProvider>();
        if (widget.isPassword) {
          return provider.validatePassword(value);
        }
        return provider.validateEmail(value);
      },
      onTapUpOutside: (event) => FocusScope.of(context).unfocus(),
    );
  }
}
