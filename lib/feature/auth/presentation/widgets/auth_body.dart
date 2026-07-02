import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/services/locale_service.dart';
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
    context.watch<LocaleProvider>(); // rebuilds this subtree when locale changes
    return Consumer<SignInProvider>(
      builder: (context, viewModel, _) => SingleChildScrollView(
        child: Form(
          key: viewModel.formKey,
          child: Column(
            children: [
              SignInTextStyle(),
              Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  top: 16,
                  bottom: 16,
                ),
                child: Column(
                  children: [
                    AuthTextField(
                      controller: viewModel.emailController,
                      title: 'email_address'.tr(),
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 10),
                    AuthTextField(
                      controller: viewModel.passController,
                      title: 'password'.tr(),
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 10),
                    AuthButtons(isLoading: viewModel.isLoading),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
