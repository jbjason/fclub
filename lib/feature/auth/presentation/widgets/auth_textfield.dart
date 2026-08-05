import 'package:fclub/core/util/my_dimens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    required this.controller,
    required this.title,
    required this.prefixIcon,
    required this.validator,
    this.isPassword = false,
    super.key,
  });
  final TextEditingController controller;
  final String title;
  final IconData prefixIcon;
  final FormFieldValidator<String> validator;
  final bool isPassword;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // title text
        Text(
          widget.title,
          style: GoogleFonts.fjallaOne(
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
        ),
        const SizedBox(height: 2),
        //  textfield
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: MyDimens.loginGradient,
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword && _obscureText,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Icon(widget.prefixIcon, color: Colors.grey, size: 20),
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
                      onPressed: () =>
                          setState(() => _obscureText = !_obscureText),
                    )
                  : null,
              errorStyle: TextStyle(color: Colors.white, fontSize: 11),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
            // style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            //   fontWeight: FontWeight.normal,
            //   color: Colors.white,
            //   fontSize: 14,
            // ),
            validator: widget.validator,
            onTapUpOutside: (event) => FocusScope.of(context).unfocus(),
          ),
        ),
      ],
    );
  }
}
