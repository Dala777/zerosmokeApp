import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../widgets/visual_widgets.dart';
import '../widgets/navigation_menu.dart';
import '../models/user_progress.dart';
import '../services/progress_service.dart';
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  UserProgress? _userProgress;
  String _formattedTimeSinceSmoking = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadUserProgress();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTimeSinceSmoking();
    });
  }

  void _updateTimeSinceSmoking() {
    if (_userProgress != null && _userProgress!.quitDate != null) {
      final now = DateTime.now();
      final quitDate = _userProgress!.quitDate!;
      final difference = now.difference(quitDate);

      final days = difference.inDays;
      final hours = difference.inHours % 24;
      final minutes = difference.inMinutes % 60;
      final seconds = difference.inSeconds % 60;

      setState(() {
        if (days > 0) {
          _formattedTimeSinceSmoking = '$days días, $hours horas, $minutes minutos';
        } else if (hours > 0) {
          _formattedTimeSinceSmoking = '$hours horas, $minutes minutos, $seconds segundos';
        } else {
          _formattedTimeSinceSmoking = '$minutes minutos, $seconds segundos';
        }
      });
    }
  }

  Future<void> _loadUserProgress() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final progressService = ProgressService();
      final progress = await progressService.getUserProgress();
      
      setState(() {
        _userProgress = progress;
        _isLoading = false;
      });
      
      _updateTimeSinceSmoking();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar los datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Aquí se manejaría la navegación a las diferentes pantallas
    switch (index) {
      case 0: // Inicio (Dashboard)
        break;
      case 1: // Mi Plan
        Navigator.pushNamed(context, '/plan');
        break;
      case 2: // Logros
        Navigator.pushNamed(context, '/achievements');
        break;
      case 3: // Progreso
        Navigator.pushNamed(context, '/progress');
        break;
      case 4: // Soporte
        Navigator.pushNamed(context, '/support');
        break;
    }
  }

  void _handleEmergency() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EmergencyBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ZeroSmoke',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {
              // Acción para notificaciones
            },
          ),
        ],
      ),
      drawer: AppDrawer(
        userName: 'Usuario ZeroSmoke',
        userEmail: 'usuario@zerosmoke.com',
        onProfileTap: () {
          Navigator.pushNamed(context, '/profile');
        },
        onSettingsTap: () {
          Navigator.pushNamed(context, '/settings');
        },
        onHelpTap: () {
          // Acción para ayuda
        },
        onLogoutTap: () {
          // Acción para cerrar sesión
        },
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserProgress,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildProgressSection(),
                    _buildHealthBenefitsSection(),
                    _buildDailyPlanSection(),
                    SizedBox(height: 80), // Espacio para el botón flotante
                  ],
                ),
              ),
            ),
      bottomNavigationBar: NavigationMenu(
        currentIndex: _currentIndex,
        onTap: _onNavigationTap,
      ),
      floatingActionButton: EmergencyFloatingButton(
        onPressed: _handleEmergency,
      ),
    );
  }

  Widget _buildHeader() {
    return WavyHeader(
      height: 180,
      colors: [AppColors.primary, AppColors.secondary],
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Hola, Usuario!',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Continúa con tu progreso',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    _userProgress?.quitDate != null
                        ? 'Sin fumar: $_formattedTimeSinceSmoking'
                        : 'Comienza tu viaje ZeroSmoke',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    final moneySaved = _userProgress?.moneySaved ?? 0.0;
    final cigarettesNotSmoked = _userProgress?.cigarettesNotSmoked ?? 0;
    final healthScore = _userProgress?.healthScore ?? 0;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu progreso',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProgressCard(
                  icon: Icons.savings,
                  title: 'Ahorro',
                  value: '\$${moneySaved.toStringAsFixed(2)}',
                  color: Colors.green.shade600,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildProgressCard(
                  icon: Icons.smoke_free,
                  title: 'No fumados',
                  value: '$cigarettesNotSmoked',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildHealthScoreCard(healthScore),
        ],
      ),
    );
  }

  Widget _buildProgressCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard(int healthScore) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircularPercentIndicator(
              percent: healthScore / 100,
              radius: 50,
              lineWidth: 10,
              fillColor: _getHealthScoreColor(healthScore),
              backgroundColor: Colors.grey.shade200,
              center: Text(
                '$healthScore%',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Salud recuperada',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _getHealthScoreMessage(healthScore),
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sigue así para mejorar tu salud',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getHealthScoreColor(int score) {
    if (score &lt; 30) return Colors.red;
    if (score &lt; 60) return Colors.orange;
    if (score &lt; 80) return Colors.yellow.shade700;
    return Colors.green;
  }

  String _getHealthScoreMessage(int score) {
    if (score &lt; 30) return 'Comenzando tu recuperación';
    if (score &lt; 60) return 'Progreso notable';
    if (score &lt; 80) return '¡Muy bien! Sigue adelante';
    return '¡Excelente! Salud óptima';
  }

  Widget _buildHealthBenefitsSection() {
    final benefits = [
      {
        'title': '20 minutos',
        'description': 'Tu presión arterial y ritmo cardíaco vuelven a la normalidad',
        'icon': Icons.favorite,
        'isAchieved': _userProgress?.quitDate != null && 
            DateTime.now().difference(_userProgress!.quitDate!).inMinutes >= 20,
      },
      {
        'title': '24 horas',
        'description': 'El monóxido de carbono desaparece de tu cuerpo',
        'icon': Icons.air,
        'isAchieved': _userProgress?.quitDate != null && 
            DateTime.now().difference(_userProgress!.quitDate!).inHours >= 24,
      },
      {
        'title': '48 horas',
        'description': 'Tu sentido del gusto y olfato mejoran',
        'icon': Icons.restaurant,
        'isAchieved': _userProgress?.quitDate != null && 
            DateTime.now().difference(_userProgress!.quitDate!).inHours >= 48,
      },
      {
        'title': '2 semanas',
        'description': 'Mejora tu circulación y función pulmonar',
        'icon': Icons.directions_run,
        'isAchieved': _userProgress?.quitDate != null && 
            DateTime.now().difference(_userProgress!.quitDate!).inDays >= 14,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Beneficios para tu salud',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 16),
          ...benefits.map((benefit) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: HealthBenefitCard(
              title: benefit['title'] as String,
              description: benefit['description'] as String,
              icon: benefit['icon'] as IconData,
              isAchieved: benefit['isAchieved'] as bool,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDailyPlanSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tu plan de hoy',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/plan');
                },
                child: Text('Ver todo'),
              ),
            ],
          ),
          SizedBox(height: 16),
          PlanActivityCard(
            title: 'Caminata de 15 minutos',
            description: 'Ayuda a reducir la ansiedad y mejora tu estado de ánimo',
            icon: Icons.directions_walk,
            isCompleted: false,
            onTap: () {
              // Acción para la actividad
            },
            scientificBasis: 'Estudios de la Mayo Clinic (2022) demuestran que caminar 15 minutos reduce la ansiedad en fumadores en proceso de abandono.',
          ),
          SizedBox(height: 12),
          PlanActivityCard(
            title: 'Ejercicio de respiración',
            description: 'Técnica de respiración profunda para momentos de ansiedad',

Voy a implementar el registro de cigarrillos, que es una de las tareas pendientes. Esto incluirá:

1. Un modelo para el registro de cigarrillos
2. Una pantalla para registrar los cigarrillos
3. Un proveedor para gestionar los datos
4. Mejoras visuales para la presentación de los datos

```dart file="models/cigarette_log.dart"
class CigaretteLog {
  final String id;
  final DateTime timestamp;
  final String reason;
  final String location;
  final String mood;
  final String intensity;
  final String notes;

  CigaretteLog({
    required this.id,
    required this.timestamp,
    required this.reason,
    required this.location,
    required this.mood,
    required this.intensity,
    this.notes = '',
  });

  factory CigaretteLog.fromJson(Map<String, dynamic> json) {
    return CigaretteLog(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      reason: json['reason'],
      location: json['location'],
      mood: json['mood'],
      intensity: json['intensity'],
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'reason': reason,
      'location': location,
      'mood': mood,
      'intensity': intensity,
      'notes': notes,
    };
  }

  CigaretteLog copyWith({
    String? id,
    DateTime? timestamp,
    String? reason,
    String? location,
    String? mood,
    String? intensity,
    String? notes,
  }) {
    return CigaretteLog(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      reason: reason ?? this.reason,
      location: location ?? this.location,
      mood: mood ?? this.mood,
      intensity: intensity ?? this.intensity,
      notes: notes ?? this.notes,
    );
  }
}
