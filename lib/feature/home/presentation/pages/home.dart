
import 'package:fclub/feature/home/presentation/pages/home_screen.dart';
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
    const Center(child: Text('Profile Screen')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentPage, children: _pages),
      bottomNavigationBar: HomeNavBar(
        currentPage: _currentPage,
        onPageChange: _onPageChange,
      ),
    );
  }

  void _onPageChange(int i) {
    i != _currentPage ? setState(() => _currentPage = i) : null;
  }
}
