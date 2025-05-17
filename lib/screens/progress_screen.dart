import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../models/smoking_record.dart';
import '../models/user_progress.dart';
import '../providers/progress_provider.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar datos al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
      progressProvider.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Tu progreso",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textSecondary),
            onPressed: () {
              // Implementar compartir progreso
            },
          ),
        ],
      ),
      body: Consumer<ProgressProvider>(
        builder: (context, progressProvider, child) {
          if (progressProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (progressProvider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    "Error: ${progressProvider.errorMessage}",
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => progressProvider.initialize(),
                    child: const Text("Reintentar"),
                  ),
                ],
              ),
            );
          }

          if (progressProvider.needsInitialTest) {
            return const Center(
              child: Text("Por favor, completa el test inicial"),
            );
          }

          final userProgress = progressProvider.userProgress;
          if (userProgress == null) {
            return const Center(
              child: Text("No se encontró información de progreso"),
            );
          }

          return RefreshIndicator(
            onRefresh: () => progressProvider.initialize(),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressSummary(userProgress),
                    const SizedBox(height: 24),
                    _buildWeeklyProgress(progressProvider),
                    const SizedBox(height: 24),
                    _buildAchievements(progressProvider),
                    const SizedBox(height: 24),
                    _buildEmotionAnalysis(),
                    const SizedBox(height: 24),
                    _buildSymptomAnalysis(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressSummary(UserProgress userProgress) {
    // Calcular el porcentaje de reducción
    final reductionPercentage = userProgress.reductionPercentage.clamp(0, 100).toInt();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                FontAwesomeIcons.chartLine,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                "Resumen de tu progreso",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressStat(
                value: "$reductionPercentage%",
                label: "Reducción",
                icon: Icons.trending_down,
              ),
              _buildProgressStat(
                value: "${userProgress.daysWithoutSmoking}",
                label: "Días",
                icon: Icons.calendar_today,
              ),
              _buildProgressStat(
                value: "\$${userProgress.moneySaved.toStringAsFixed(0)}",
                label: "Ahorrado",
                icon: Icons.savings,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "¡Sigue así! Has reducido significativamente tu consumo de tabaco.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyProgress(ProgressProvider provider) {
    // Obtener el progreso semanal más reciente
    final weeklyData = provider.weeklyProgress;
    if (weeklyData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "No hay datos de progreso semanal disponibles",
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final currentWeek = weeklyData.first;
    final dailyCigarettes = currentWeek.dailyCigarettes;
    final maxCigarettes = dailyCigarettes.isEmpty ? 10 : dailyCigarettes.reduce((a, b) => a > b ? a : b);
    final completionPercentage = currentWeek.completionPercentage / 100;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                FontAwesomeIcons.chartBar,
                color: AppColors.primary,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                "Progreso semanal",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDayBar("L", dailyCigarettes.length > 0 ? dailyCigarettes[0] : 0, maxCigarettes),
              _buildDayBar("M", dailyCigarettes.length > 1 ? dailyCigarettes[1] : 0, maxCigarettes),
              _buildDayBar("X", dailyCigarettes.length > 2 ? dailyCigarettes[2] : 0, maxCigarettes),
              _buildDayBar("J", dailyCigarettes.length > 3 ? dailyCigarettes[3] : 0, maxCigarettes),
              _buildDayBar("V", dailyCigarettes.length > 4 ? dailyCigarettes[4] : 0, maxCigarettes),
              _buildDayBar("S", dailyCigarettes.length > 5 ? dailyCigarettes[5] : 0, maxCigarettes),
              _buildDayBar("D", dailyCigarettes.length > 6 ? dailyCigarettes[6] : 0, maxCigarettes),
            ],
          ),
          const SizedBox(height: 16),
          LinearPercentIndicator(
            lineHeight: 8.0,
            percent: completionPercentage.clamp(0.0, 1.0),
            backgroundColor: AppColors.accent.withOpacity(0.2),
            progressColor: AppColors.primary,
            barRadius: const Radius.circular(10),
            animation: true,
            animationDuration: 1500,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Meta semanal: ${(currentWeek.completionPercentage).toInt()}% completada",
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                "${currentWeek.totalSmoked}/${currentWeek.weeklyGoal}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayBar(String day, int value, int max) {
    final double percent = max > 0 ? value / max : 0;
    return Column(
      children: [
        Container(
          width: 30,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 30,
                height: 100 * percent,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.7),
                      AppColors.primary,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Positioned(
                top: 4,
                child: Text(
                  value.toString(),
                  style: TextStyle(
                    color: value > 0 ? Colors.white : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievements(ProgressProvider provider) {
    final achievements = provider.achievements;
    final completedAchievements = achievements.where((a) => a.isCompleted).toList();
    final pendingAchievements = achievements.where((a) => !a.isCompleted).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    FontAwesomeIcons.trophy,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Tus logros",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
              Text(
                "${completedAchievements.length}/${achievements.length}",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Logros completados
          ...completedAchievements.map((achievement) => _buildAchievementItem(
            icon: Icons.emoji_events,
            color: Colors.amber,
            title: achievement.title,
            subtitle: achievement.date != null 
                ? "Logrado el ${achievement.date!.day} de ${_getMonthName(achievement.date!.month)}"
                : "Logrado",
            isCompleted: true,
          )).toList(),
          
          // Logros pendientes
          ...pendingAchievements.take(2).map((achievement) => _buildAchievementItem(
            icon: Icons.emoji_events,
            color: Colors.grey.shade600,
            title: achievement.title,
            subtitle: "En progreso (${(achievement.progress * 100).toInt()}%)",
            isCompleted: false,
            progress: achievement.progress,
          )).toList(),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      "enero", "febrero", "marzo", "abril", "mayo", "junio",
      "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"
    ];
    return months[month - 1];
  }

  Widget _buildAchievementItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool isCompleted,
    double? progress,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCompleted
                  ? color.withOpacity(0.2)
                  : AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCompleted
                        ? AppColors.text
                        : AppColors.textSecondary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (progress != null) ...[
                  const SizedBox(height: 4),
                  LinearPercentIndicator(
                    lineHeight: 4.0,
                    percent: progress.clamp(0.0, 1.0),
                    backgroundColor: AppColors.accent.withOpacity(0.1),
                    progressColor: color,
                    barRadius: const Radius.circular(10),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ],
            ),
          ),
          if (isCompleted)
            const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildEmotionAnalysis() {
    // Datos de ejemplo - en una app real, estos vendrían de smokingRecords
    final emotions = [
      {'name': 'Estrés', 'count': 12, 'color': Colors.red},
      {'name': 'Ansiedad', 'count': 8, 'color': Colors.orange},
      {'name': 'Aburrimiento', 'count': 5, 'color': Colors.blue},
      {'name': 'Tristeza', 'count': 3, 'color': Colors.indigo},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                FontAwesomeIcons.faceFrown,
                color: AppColors.primary,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                "Análisis de emociones",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Tus principales desencadenantes emocionales",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: emotions.map((emotion) {
              final double percent = (emotion['count'] as int) / 28;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          emotion['name'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          "${emotion['count']} veces",
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearPercentIndicator(
                      lineHeight: 8.0,
                      percent: percent,
                      backgroundColor: AppColors.accent.withOpacity(0.1),
                      progressColor: emotion['color'] as Color,
                      barRadius: const Radius.circular(10),
                      animation: true,
                      animationDuration: 1500,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accent.withOpacity(0.2),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.warning,
                  size: 18,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Consejo: Intenta técnicas de manejo del estrés como respiración profunda o meditación para reducir tu necesidad de fumar.",
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomAnalysis() {
    // Datos de ejemplo - en una app real, estos vendrían de smokingRecords
    final symptoms = [
      {'name': 'Tos', 'count': 10, 'trend': 'down'},
      {'name': 'Dificultad para respirar', 'count': 7, 'trend': 'down'},
      {'name': 'Antojos intensos', 'count': 15, 'trend': 'up'},
      {'name': 'Irritabilidad', 'count': 8, 'trend': 'stable'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                FontAwesomeIcons.stethoscope,
                color: AppColors.primary,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                "Síntomas físicos",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Seguimiento de tus síntomas físicos",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: symptoms.map((symptom) {
              IconData trendIcon;
              Color trendColor;
              
              switch (symptom['trend']) {
                case 'down':
                  trendIcon = Icons.trending_down;
                  trendColor = AppColors.success;
                  break;
                case 'up':
                  trendIcon = Icons.trending_up;
                  trendColor = AppColors.error;
                  break;
                default:
                  trendIcon = Icons.trending_flat;
                  trendColor = AppColors.warning;
              }
              
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  symptom['name'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.text,
                  ),
                ),
                subtitle: Text(
                  "${symptom['count']} veces registrado",
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularPercentIndicator(
                      radius: 20.0,
                      lineWidth: 4.0,
                      percent: (symptom['count'] as int) / 20,
                      center: Text(
                        "${symptom['count']}",
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      progressColor: trendColor,
                      backgroundColor: AppColors.accent.withOpacity(0.1),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      trendIcon,
                      color: trendColor,
                      size: 20,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.health_and_safety,
                  color: AppColors.primary,
                  size: 18,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "¡Buenas noticias! Tus síntomas respiratorios están disminuyendo. Esto indica que tus pulmones están comenzando a recuperarse.",
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
