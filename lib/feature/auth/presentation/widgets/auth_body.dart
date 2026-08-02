import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/services/locale_service.dart';
import 'package:fclub/feature/auth/presentation/provider/signin_provider.dart';
import 'package:fclub/feature/auth/presentation/widgets/auth_buttons.dart';
import 'package:fclub/feature/auth/presentation/widgets/auth_top_text.dart';
import 'package:fclub/feature/auth/presentation/widgets/auth_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthBody extends StatefulWidget {
  const AuthBody({super.key});
  @override
  State<AuthBody> createState() => _AuthBodyState();
}

class _AuthBodyState extends State<AuthBody> {
  File? _userImageFile;
  bool isLogIn = true;

  @override
  Widget build(BuildContext context) {
    context
        .watch<LocaleProvider>(); // rebuilds this subtree when locale changes
    return Consumer<SignInProvider>(
      builder: (context, viewModel, _) => SingleChildScrollView(
        child: Form(
          key: viewModel.formKey,
          child: Column(
            children: [
              AuthTopText(isLogin: isLogIn, pickedImage: _pickedImage),
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
                    if (!isLogIn) ...[
                      AuthTextField(
                        controller: viewModel.usernameController,
                        title: 'Username',
                        prefixIcon: Icons.person_outline,
                      ),
                      const SizedBox(height: 10),
                    ],
                    AuthTextField(
                      controller: viewModel.passController,
                      title: 'password'.tr(),
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 30),
                    AuthButtons(
                      isLoading: viewModel.isLoading,
                      isLogin: isLogIn,
                      onChanginSingInState: () =>
                          setState(() => isLogIn = !isLogIn),
                      onPress: () => _onSubmit(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickedImage(File image) => _userImageFile = image;
  void _onSubmit(BuildContext context) async {
    final provider = context.read<SignInProvider>();
    FocusScope.of(context).unfocus();
    await provider.signIn(context);
  }
}
