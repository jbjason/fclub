import 'package:fclub/feature/auth/presentation/provider/signin_provider.dart';
import 'package:fclub/feature/auth/presentation/widgets/auth_buttons.dart';
import 'package:fclub/feature/auth/presentation/widgets/auth_sign_in_text.dart';
import 'package:fclub/feature/auth/presentation/widgets/auth_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthBody extends StatelessWidget {
  const AuthBody({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<SignInProvider>(
      builder: (context, viewModel, _) => SingleChildScrollView(
        child: Form(
          key: viewModel.formKey,
          child: Column(
            children: [
              // sign in text
              SignInTextStyle(),
              Padding(
                padding: const EdgeInsets.only(
                  left: 56,
                  right: 16,
                  top: 10,
                  bottom: 16,
                ),
                child: Column(
                  children: [
                    // email textfield
                    AuthTextField(
                      controller: viewModel.emailController,
                      title: 'Email Address',
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 10),
                    // pass textfield
                    AuthTextField(
                      controller: viewModel.passController,
                      title: 'Password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 10),
                    // submit, signup & sigin buttons
                    AuthButtons(isLoading: viewModel.isLoading),
                  ],
                ),
              ),

              const SizedBox(height: 0),
            ],
          ),
        ),
      ),
    );
  }
}
