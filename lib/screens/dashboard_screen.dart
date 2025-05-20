import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../providers/auth_provider.dart';
import '../providers/progress_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/emergency_button_widget.dart';
import '../widgets/navigation_menu.dart';
import '../widgets/health_benefit_widget.dart';
import '../widgets/progress_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      await progressProvider.fetchUserProgress(authProvider.user!.id);
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
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
    final progressProvider = Provider.of<ProgressProvider>(context);
    final progress = progressProvider.userProgress;
    final quitDate = progress?.quitDate;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Progreso'),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (quitDate != null) ...[
                    _buildDaysCounter(quitDate),
                    const SizedBox(height: 24),
                  ],
                  _buildHealthScore(progress?.healthScore ?? 0),
                  const SizedBox(height: 24),
                  _buildSavingsAndCigarettes(
                    progress?.moneySaved ?? 0,
                    progress?.cigarettesNotSmoked ?? 0,
                  ),
                  const SizedBox(height: 24),
                  _buildHealthBenefits(),
                  const SizedBox(height: 24),
                  _buildPlanActivities(),
                ],
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

  Widget _buildPlanActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Plan de hoy',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/plan');
              },
              child: const Text('Ver todo'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              PlanActivityCard(
                title: 'Respiración',
                description: 'Ejercicio de 5 minutos',
                icon: Icons.air,
                color: Colors.blue,
              ),
              SizedBox(width: 12),
              PlanActivityCard(
                title: 'Beber agua',
                description: '2 vasos más hoy',
                icon: Icons.water_drop,
                color: Colors.cyan,
              ),
              SizedBox(width: 12),
              PlanActivityCard(
                title: 'Caminar',
                description: '15 minutos al aire libre',
                icon: Icons.directions_walk,
                color: Colors.green,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getColorForScore(int score) {
    if (score &lt; 30) return Colors.red;
    if (score &lt; 60) return Colors.orange;
    if (score &lt; 80) return Colors.amber;
    return Colors.green;
  }

  String _getHealthMessage(int score) {
    if (score &lt; 30) return 'Tu salud está mejorando, ¡sigue así!';
    if (score &lt; 60) return 'Buen progreso, estás en el camino correcto';
    if (score &lt; 80) return '¡Excelente! Tu cuerpo está recuperándose';
    return '¡Felicidades! Tu salud ha mejorado significativamente';
  }
}

// Widget para mostrar actividades del plan
class PlanActivityCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const PlanActivityCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para el bottom sheet de emergencia
class EmergencyBottomSheet extends StatelessWidget {
  const EmergencyBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '¿Estás teniendo un momento difícil?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aquí tienes algunas técnicas que pueden ayudarte a superar este momento:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          _buildEmergencyOption(
            context,
            'Ejercicio de respiración',
            Icons.air,
            Colors.blue,
            () => Navigator.pushNamed(context, '/breathing'),
          ),
          const SizedBox(height: 12),
          _buildEmergencyOption(
            context,
            'Beber un vaso de agua',
            Icons.water_drop,
            Colors.cyan,
            () => Navigator.pushNamed(context, '/drink-water'),
          ),
          const SizedBox(height: 12),
          _buildEmergencyOption(
            context,
            'Dar un paseo corto',
            Icons.directions_walk,
            Colors.green,
            () => Navigator.pushNamed(context, '/walking'),
          ),
          const SizedBox(height: 12),
          _buildEmergencyOption(
            context,
            'Leer una frase motivadora',
            Icons.format_quote,
            Colors.purple,
            () => Navigator.pushNamed(context, '/quotes'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            ),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyOption(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
