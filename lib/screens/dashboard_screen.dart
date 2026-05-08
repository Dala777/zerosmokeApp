import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'initial_test_screen.dart';
import 'gamification_screen.dart';
import '../theme/app_colors.dart';
import '../providers/progress_provider.dart';
import '../models/daily_checkin.dart';
import '../widgets/daily_checkin_widget.dart';
import 'plan_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  String _error = '';
  bool _showingCheckInModal = false;

  final List<Widget> _screens = [
    const HomeScreen(),
    const PlanScreen(),
    const ProgressScreen(),
    const GamificationScreen(),
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
      final prefs = await SharedPreferences.getInstance();
      final lastCheckInDate = prefs.getString('lastCheckInDate');

      final today = DateTime.now();
      final todayString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      if (lastCheckInDate != todayString) {
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
      final prefs = await SharedPreferences.getInstance();
      final todayString =
          '${checkIn.date.year}-${checkIn.date.month.toString().padLeft(2, '0')}-${checkIn.date.day.toString().padLeft(2, '0')}';

      await prefs.setString('lastCheckInDate', todayString);
      await prefs.setString('lastCheckInData', checkIn.toJson().toString());

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

  void _showEmergencyBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EmergencyBottomSheet(),
    );
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
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showEmergencyBottomSheet,
        backgroundColor: Colors.red,
        child: const Icon(Icons.emergency, color: Colors.white),
      ),
      bottomNavigationBar: NavigationMenu(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          switch (index) {
            case 0:
              // Ya estamos en Dashboard
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/plan');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/progress');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildDaysCounter(DateTime quitDate) {
    final difference = DateTime.now().difference(quitDate);
    final days = difference.inDays;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Días sin fumar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$days',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.accentColor,
              ),
            ),
            Text(
              'Desde ${_formatDate(quitDate)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScore(int score) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Puntuación de salud',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: CircularPercentIndicator(
                radius: 80,
                lineWidth: 12,
                percent: score / 100,
                center: Text(
                  '$score%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                progressColor: _getColorForScore(score),
                backgroundColor: Colors.grey[300]!,
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
                animationDuration: 1500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getHealthMessage(score),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsAndCigarettes(double moneySaved, int cigarettesNotSmoked) {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(
                    Icons.savings,
                    size: 32,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Dinero ahorrado',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${moneySaved.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(
                    Icons.smoke_free,
                    size: 32,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cigarrillos no fumados',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$cigarettesNotSmoked',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthBenefits() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Beneficios para tu salud',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const HealthBenefitWidget(),
      ],
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
      ],
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
