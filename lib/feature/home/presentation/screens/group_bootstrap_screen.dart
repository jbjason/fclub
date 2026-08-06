import 'package:fclub/feature/home/data/repositories/group_repository.dart';
import 'package:fclub/feature/home/presentation/provider/group_bootstrap_provider.dart';
import 'package:fclub/feature/home/presentation/provider/group_session_provider.dart';
import 'package:fclub/feature/home/presentation/screens/group_gateway_screen.dart';
import 'package:fclub/feature/home/presentation/screens/home.dart';
import 'package:fclub/feature/home/presentation/widgets/group_bootstrap_widgets/group_session_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupBootstrapScreen extends StatelessWidget {
  const GroupBootstrapScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GroupBootstrapProvider(
        repository: context.read<GroupRepository>(),
        groupSession: context.read<GroupSessionProvider>(),
      )..initialize(userId: userId),
      child: Consumer<GroupBootstrapProvider>(
        builder: (context, provider, _) => switch (provider.status) {
          GroupBootstrapStatus.checking => const GroupSessionLoadingScreen(),
          GroupBootstrapStatus.gateway => const GroupGatewayScreen(),
          GroupBootstrapStatus.home => const Home(),
        },
      ),
    );
  }
}
