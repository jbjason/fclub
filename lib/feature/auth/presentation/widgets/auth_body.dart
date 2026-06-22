import 'package:fclub/feature/auth/presentation/provider/signin_provider.dart';
import 'package:fclub/feature/auth/presentation/widgets/auth_buttons.dart';
import 'package:fclub/feature/auth/presentation/widgets/auth_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuhtBody extends StatelessWidget {
  const AuhtBody({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<SignInProvider>(
      builder: (context, viewModel, _) => SingleChildScrollView(
        child: Form(
          key: viewModel.formKey,
          child: Column(
            children: [
              // login text & Image circleAvatar
              Center(
                child: Text(
                  'LOGIN',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              // email textfield
              AuthTextField(
                controller: viewModel.emailController,
                title: 'Email',
              ),
              // pass textfield
              AuthTextField(
                controller: viewModel.passController,
                title: 'Password',
              ),
              const SizedBox(height: 20),
              // submit, signup & sigin buttons
              AuthButtons(
                isLoading: viewModel.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }


}
