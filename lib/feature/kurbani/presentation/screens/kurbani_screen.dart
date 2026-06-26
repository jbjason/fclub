import 'package:fclub/feature/kurbani/presentation/screens/kurbani_history_screen.dart';
import 'package:flutter/material.dart';

/// Entry point for the Kurbani feature.
///
/// The global [KurbaniProvider] is already available from the app-level
/// [MultiProvider] in main.dart, so this widget simply lands on
/// [KurbaniHistoryScreen] directly.
class KurbaniScreen extends StatelessWidget {
  const KurbaniScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const KurbaniHistoryScreen();
  }
}
