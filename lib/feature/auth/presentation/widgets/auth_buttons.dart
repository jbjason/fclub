import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:flutter/material.dart';

class AuthButtons extends StatelessWidget {
  const AuthButtons({
    required this.isLoading,
    super.key,
    required this.isLogin,
    this.onPress,
    this.onChanginSingInState,
  });
  final bool isLoading;
  final bool isLogin;
  final VoidCallback? onChanginSingInState;
  final VoidCallback? onPress;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? const CircularProgressIndicator()
          :
            // signIn text
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: onPress,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      shadowColor: Colors.black,
                      backgroundColor: Colors.transparent,
                      elevation: 15,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            MyColor.logGradient1Color,
                            MyColor.logGradient2Color,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          (isLogin ? 'sign_in' : 'create_account').tr(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  child: TextButton(
                    onPressed: onChanginSingInState,
                    child: Text(
                      (isLogin
                              ? 'auth_create_new_account'
                              : 'auth_already_have_account')
                          .tr(),
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
