import 'package:flutter/material.dart';
import '../widgets/navigation_menu.dart';
import 'dashboard_screen.dart';
import 'progress_screen.dart';
import 'plan_screen.dart';
import 'profile_screen.dart';
import 'cigarette_log_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    DashboardScreen(),
    ProgressScreen(),
    PlanScreen(),
    CigaretteLogScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationMenu(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
