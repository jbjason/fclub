import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repository/pack_check_repository.dart';
import '../provider/pack_check_provider.dart';
import 'pack_history_screen.dart';

/// Entry point for the Carry Check feature.
///
/// Creates a single [PackCheckProvider] shared across both pages:
/// - [PackHistoryScreen] – history list and session launcher
/// - [PackSessionScreen] – step-by-step active session flow (reached via
///   [PackHistoryScreen.goToSession]).
class PackCheckScreen extends StatelessWidget {
  const PackCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PackCheckProvider(PackCheckRepository()),
      child: const PackHistoryScreen(),
    );
  }
}
