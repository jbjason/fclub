import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/services/locale_service.dart';
import 'package:fclub/core/util/my_dialog.dart';
import 'package:fclub/feature/auth/data/model/auth_action_result.dart';
import 'package:fclub/feature/auth/presentation/provider/signin_provider.dart';
import 'package:fclub/feature/auth/presentation/widgets/auth_buttons.dart';
import 'package:fclub/feature/auth/presentation/widgets/auth_password_reset_sheet.dart';
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
              AuthTopText(isLogin: isLogIn, pickedImage: (_) {}),
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
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: viewModel.validateEmail,
                    ),
                    const SizedBox(height: 10),
                    if (!isLogIn) ...[
                      AuthTextField(
                        controller: viewModel.usernameController,
                        title: 'name'.tr(),
                        prefixIcon: Icons.person_outline,
                        validator: viewModel.validateName,
                      ),
                      const SizedBox(height: 10),
                    ],
                    AuthTextField(
                      controller: viewModel.passController,
                      title: 'password'.tr(),
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      validator: viewModel.validatePassword,
                    ),
                    if (isLogIn)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: viewModel.isLoading
                              ? null
                              : () => _showPasswordReset(context, viewModel),
                          child: Text(
                            'auth_forgot_password'.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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

  Future<void> _showPasswordReset(
    BuildContext context,
    SignInProvider provider,
  ) async {
    FocusScope.of(context).unfocus();
    final result = await showModalBottomSheet<AuthActionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AuthPasswordResetSheet(
        initialEmail: provider.emailController.text,
        onSubmit: provider.sendPasswordResetEmail,
      ),
    );
    if (!context.mounted || result == null || !result.isSuccess) return;
    MyDialog().showSuccessToast(
      msg: 'auth_reset_email_sent'.tr(),
      context: context,
    );
  }

  Future<void> _onSubmit(BuildContext context) async {
    final provider = context.read<SignInProvider>();
    FocusScope.of(context).unfocus();

    if (isLogIn) {
      await provider.signIn(context);
    } else {
      await provider.signUp(context);
    }
  }
}
