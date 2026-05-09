import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'initial_test_screen.dart';
import 'gamification_screen.dart';
import 'chat_screen.dart';
import '../theme/app_colors.dart';
import '../providers/progress_provider.dart';
import '../models/daily_checkin.dart';
import '../widgets/daily_checkin_widget.dart';
import 'plan_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  String _error = '';
  bool _showingCheckInModal = false;

  final List<Widget> _screens = [
    const HomeScreen(),
    const PlanScreen(),
    const ProgressScreen(),
    const GamificationScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _checkInitialTest();
      await _checkDailyCheckIn();
    });
  }

  Future<void> _checkInitialTest() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      final progressProvider =
          Provider.of<ProgressProvider>(context, listen: false);
      await progressProvider.initialize();

      if (progressProvider.needsInitialTest) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const InitialTestScreen()),
          );
          return;
        }
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
      print('Error en _checkInitialTest: $_error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkDailyCheckIn() async {
    if (!mounted || _showingCheckInModal) return;

    try {
      final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
      await progressProvider.getTodayDailyCheckIn();

      if (progressProvider.todayCheckIn == null) {
        if (mounted && !_showingCheckInModal) {
          setState(() => _showingCheckInModal = true);

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Dialog(
              insetPadding: const EdgeInsets.all(16),
              backgroundColor: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: DailyCheckInWidget(
                isModal: true,
                onSubmit: _handleCheckInSubmit,
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error checking daily check-in: $e');
    }
  }

  void _handleCheckInSubmit(DailyCheckIn checkIn) async {
    if (!mounted) return;

    try {
      final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
      final success = await progressProvider.saveDailyCheckIn(checkIn);
      if (!success) {
        throw Exception(progressProvider.errorMessage);
      }

      if (mounted) {
        setState(() => _showingCheckInModal = false);

        // ✅ Sin Navigator.pop() aquí — el widget ya lo hace internamente
        // en su método _submitCheckIn() cuando isModal == true

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Check-in completado! Excelente trabajo.'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error saving check-in: $e');
      if (mounted) {
        setState(() => _showingCheckInModal = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar check-in: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'Cargando tu información...',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  setState(() => _error = '');
                  await _checkInitialTest();
                  await _checkDailyCheckIn();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: AppColors.cardBackground,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: 'Mi Plan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart),
                label: 'Progreso',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.emoji_events_outlined),
                activeIcon: Icon(Icons.emoji_events),
                label: 'Logros',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
