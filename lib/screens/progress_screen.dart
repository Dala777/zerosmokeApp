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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
      progressProvider.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<ProgressProvider>(
        builder: (context, progressProvider, child) {
          if (progressProvider.isLoading) {
            return _buildLoadingState();
          }

          if (progressProvider.errorMessage.isNotEmpty) {
            return _buildErrorState(progressProvider);
          }

          if (progressProvider.needsInitialTest) {
            return _buildInitialTestState();
          }

          final userProgress = progressProvider.userProgress;
          if (userProgress == null) {
            return _buildNoDataState();
          }

          return RefreshIndicator(
            onRefresh: () => progressProvider.initialize(),
            color: AppColors.primary,
            backgroundColor: AppColors.cardBackground,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressSummary(userProgress),
                    const SizedBox(height: 20),
                    _buildWeeklyProgress(progressProvider),
                    const SizedBox(height: 20),
                    _buildAchievements(progressProvider),
                    const SizedBox(height: 20),
                    _buildEmotionAnalysis(),
                    const SizedBox(height: 20),
                    _buildSymptomAnalysis(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        "Tu Progreso",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 22,
          color: AppColors.text,
        ),
      ),
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: AppColors.tertiary.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.share_outlined, 
              color: AppColors.accent,
              size: 20,
            ),
            onPressed: () {
              // Implementar compartir progreso
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          const Text(
            "Cargando tu progreso...",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ProgressProvider provider) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Error al cargar datos",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => provider.initialize(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Reintentar"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialTestState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppColors.gradientPrimary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.quiz_outlined,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              "¡Empecemos!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Por favor, completa el test inicial para comenzar a ver tu progreso",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataState() {
    return const Center(
      child: Text(
        "No se encontró información de progreso",
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildProgressSummary(UserProgress userProgress) {
    final reductionPercentage = userProgress.reductionPercentage.clamp(0, 100).toInt();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.gradientSuccess,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  FontAwesomeIcons.chartLine,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Resumen de tu progreso",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
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
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "¡Excelente trabajo! Has reducido significativamente tu consumo de tabaco.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
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
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyProgress(ProgressProvider provider) {
    final weeklyData = provider.weeklyProgress;
    if (weeklyData.isEmpty) {
      return _buildEmptyCard(
        title: "Progreso semanal",
        icon: FontAwesomeIcons.chartBar,
        message: "No hay datos de progreso semanal disponibles",
      );
    }

    final currentWeek = weeklyData.first;
    final dailyCigarettes = currentWeek.dailyCigarettes;
    final maxCigarettes = dailyCigarettes.isEmpty ? 10 : dailyCigarettes.reduce((a, b) => a > b ? a : b);
    final completionPercentage = currentWeek.completionPercentage / 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: "Progreso semanal",
            icon: FontAwesomeIcons.chartBar,
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
          LinearPercentIndicator(
            lineHeight: 10.0,
            percent: completionPercentage.clamp(0.0, 1.0),
            backgroundColor: AppColors.tertiary.withOpacity(0.5),
            progressColor: AppColors.primary,
            barRadius: const Radius.circular(10),
            animation: true,
            animationDuration: 1500,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Meta semanal: ${(currentWeek.completionPercentage).toInt()}% completada",
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${currentWeek.totalSmoked}/${currentWeek.weeklyGoal}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
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
          width: 32,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.tertiary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 32,
                height: 100 * percent,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.8),
                      AppColors.primary,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              if (value > 0)
                Positioned(
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      value.toString(),
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.08),
            blurRadius: 12,
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
              _buildSectionHeader(
                title: "Tus logros",
                icon: FontAwesomeIcons.trophy,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${completedAchievements.length}/${achievements.length}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Logros completados
          ...completedAchievements.map((achievement) => _buildAchievementItem(
            icon: Icons.emoji_events,
            color: AppColors.warning,
            title: achievement.title,
            subtitle: achievement.date != null 
                ? "Logrado el ${achievement.date!.day} de ${_getMonthName(achievement.date!.month)}"
                : "Logrado",
            isCompleted: true,
          )).toList(),
          
          // Logros pendientes
          ...pendingAchievements.take(2).map((achievement) => _buildAchievementItem(
            icon: Icons.emoji_events,
            color: AppColors.textSecondary,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCompleted
                  ? color.withOpacity(0.15)
                  : AppColors.tertiary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCompleted ? color.withOpacity(0.3) : AppColors.tertiary,
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? AppColors.text
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (progress != null) ...[
                  const SizedBox(height: 8),
                  LinearPercentIndicator(
                    lineHeight: 6.0,
                    percent: progress.clamp(0.0, 1.0),
                    backgroundColor: AppColors.tertiary.withOpacity(0.5),
                    progressColor: color,
                    barRadius: const Radius.circular(10),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ],
            ),
          ),
          if (isCompleted)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.success,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmotionAnalysis() {
    final emotions = [
      {'name': 'Estrés', 'count': 12, 'color': AppColors.error},
      {'name': 'Ansiedad', 'count': 8, 'color': AppColors.warning},
      {'name': 'Aburrimiento', 'count': 5, 'color': AppColors.secondary},
      {'name': 'Tristeza', 'count': 3, 'color': AppColors.accent},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: "Análisis de emociones",
            icon: FontAwesomeIcons.faceFrown,
            subtitle: "Tus principales desencadenantes emocionales",
          ),
          const SizedBox(height: 20),
          Column(
            children: emotions.map((emotion) {
              final double percent = (emotion['count'] as int) / 28;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: emotion['color'] as Color,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              emotion['name'] as String,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "${emotion['count']} veces",
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearPercentIndicator(
                      lineHeight: 8.0,
                      percent: percent,
                      backgroundColor: AppColors.tertiary.withOpacity(0.5),
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
          const SizedBox(height: 16),
          _buildTipCard(
            icon: Icons.lightbulb_outline,
            color: AppColors.warning,
            text: "Consejo: Intenta técnicas de manejo del estrés como respiración profunda o meditación para reducir tu necesidad de fumar.",
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomAnalysis() {
    final symptoms = [
      {'name': 'Tos', 'count': 10, 'trend': 'down'},
      {'name': 'Dificultad para respirar', 'count': 7, 'trend': 'down'},
      {'name': 'Antojos intensos', 'count': 15, 'trend': 'up'},
      {'name': 'Irritabilidad', 'count': 8, 'trend': 'stable'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: "Síntomas físicos",
            icon: FontAwesomeIcons.stethoscope,
            subtitle: "Seguimiento de tus síntomas físicos",
          ),
          const SizedBox(height: 20),
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
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.tertiary.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            symptom['name'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${symptom['count']} veces registrado",
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        CircularPercentIndicator(
                          radius: 22.0,
                          lineWidth: 4.0,
                          percent: (symptom['count'] as int) / 20,
                          center: Text(
                            "${symptom['count']}",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          progressColor: trendColor,
                          backgroundColor: AppColors.tertiary.withOpacity(0.5),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: trendColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            trendIcon,
                            color: trendColor,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _buildTipCard(
            icon: Icons.health_and_safety,
            color: AppColors.success,
            text: "¡Buenas noticias! Tus síntomas respiratorios están disminuyendo. Esto indica que tus pulmones están comenzando a recuperarse.",
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTipCard({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard({
    required String title,
    required IconData icon,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSectionHeader(title: title, icon: icon),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.tertiary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.textSecondary,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}