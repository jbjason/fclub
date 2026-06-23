
import 'package:fclub/config/router/app_router.dart';
import 'package:fclub/feature/home/presentation/screens/home_screen.dart';
import 'package:fclub/feature/home/presentation/widgets/home_navbar.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentPage = 0;
  final List<Widget> _pages = [
    HomeScreen(),
    const _ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentPage, children: _pages),
      bottomNavigationBar: HomeNavBar(
        currentIndex: _currentPage,
        onTap: _onPageChange,
      ),
    );
  }

  void _onPageChange(int i) {
    i != _currentPage ? setState(() => _currentPage = i) : null;
  }
}

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () =>
              Navigator.pushNamed(context, AppRouteName.tourSetup),
          icon: const Icon(Icons.card_travel_rounded),
          label: const Text('Start a Tour'),
        ),
      ),
    );
  }
}
