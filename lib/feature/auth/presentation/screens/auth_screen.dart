import 'package:fclub/config/extension/media_query_extension.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/services/locale_service.dart';
import 'package:fclub/feature/auth/presentation/widgets/auth_body.dart';
import 'package:fclub/feature/auth/presentation/widgets/auth_clippers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.logBackColor,
      body: Stack(
        children: [
          Center(
            child: AnimatedContainer(
              width: context.screenWidth * .85,
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [MyColor.logGradient1Color, MyColor.logGradient2Color],
                ),
              ),
              child: ClipPath(
                clipper: AuthClipper(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: MyColor.logBackColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: AuthBody(),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: const _LanguageToggleButton(),
          ),
        ],
      ),
    );
  }
}

class _LanguageToggleButton extends StatelessWidget {
  const _LanguageToggleButton();

  @override
  Widget build(BuildContext context) {
    final isBn = context.watch<LocaleProvider>().languageCode == 'bn';
    return GestureDetector(
      onTap: () => context.read<LocaleProvider>().toggleLanguage(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.translate,
                color: Colors.white70, size: 14),
            const SizedBox(width: 6),
            Text(
              isBn ? 'EN' : 'বাং',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
