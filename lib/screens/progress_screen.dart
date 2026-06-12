import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../models/user_progress.dart';
import '../models/dynamic_achievement.dart';
import '../providers/progress_provider.dart';
import '../providers/gamification_provider.dart';
import '../widgets/zero_app_bar.dart';
import '../widgets/kpi_card.dart';
import '../widgets/charts/weekly_bar_chart.dart';
import '../widgets/charts/trend_line_chart.dart';
import '../widgets/charts/emotion_pie_chart.dart';
import '../widgets/charts/symptom_bar_chart.dart';

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
      Provider.of<GamificationProvider>(context, listen: false).loadDynamicAchievements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<ProgressProvider>(
        builder: (context, progressProvider, child) {
          if (progressProvider.isLoading && progressProvider.userProgress == null) {
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
                    _buildKpiGrid(userProgress),
                    const SizedBox(height: 20),
                    _buildWeeklyChart(progressProvider),
                    if (_hasMultiWeekData(progressProvider)) ...[
                      const SizedBox(height: 20),
                      _buildTrendChart(progressProvider),
                    ],
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

  bool _hasMultiWeekData(ProgressProvider provider) {
    return provider.weeklyProgress.length > 1;
  }

  PreferredSizeWidget _buildAppBar() {
    return ZeroAppBar(
      title: "Progreso",
      subtitle: "Evolución y métricas detalladas",
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
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
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
              child: const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              "Error al cargar datos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.text),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => provider.initialize(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            const Icon(Icons.quiz_outlined, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            const Text(
              "¡Empecemos!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              "Por favor, completa el test inicial para comenzar a ver tu progreso",
              style: TextStyle(color: Colors.white, fontSize: 16),
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
        style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
      ),
    );
  }

  Widget _buildKpiGrid(UserProgress userProgress) {
    final reductionPercentage = userProgress.weeklyData.isNotEmpty
        ? userProgress.weeklyData.first.completionPercentage.toInt()
        : userProgress.reductionPercentage.toInt();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: KpiCard(
                icon: Icons.calendar_today,
                value: "${userProgress.daysWithoutSmoking}",
                label: "Días sin fumar",
                gradient: AppColors.gradientSuccess,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KpiCard(
                icon: Icons.savings,
                value: "\$${userProgress.moneySaved.toStringAsFixed(0)}",
                label: "Ahorrado",
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: KpiCard(
                icon: Icons.block,
                value: "${userProgress.cigarettesAvoided}",
                label: "Cigarrillos evitados",
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KpiCard(
                icon: Icons.trending_down,
                value: "$reductionPercentage%",
                label: "Reducción",
                color: AppColors.secondary,
                progress: reductionPercentage / 100.0,
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${userProgress.cigarettesSmokedToday} hoy",
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (userProgress.planTotalDays > 0) ...[
          const SizedBox(height: 12),
          KpiCard(
            icon: Icons.route,
            value: "${userProgress.planCurrentDay}/${userProgress.planTotalDays}",
            label: "Progreso del plan",
            color: AppColors.primary,
            progress: userProgress.planProgress.clamp(0.0, 1.0),
          ),
        ],
      ],
    );
  }

  Widget _buildWeeklyChart(ProgressProvider provider) {
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
    final completionPercentage = (currentWeek.completionPercentage / 100).clamp(0.0, 1.0).toDouble();

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
          _buildSectionHeader(title: "Progreso semanal", icon: FontAwesomeIcons.chartBar),
          const SizedBox(height: 20),
          WeeklyBarChart(
            dailyCigarettes: dailyCigarettes,
            maxCigarettes: maxCigarettes,
          ),
          const SizedBox(height: 20),
          LinearPercentIndicator(
            lineHeight: 10.0,
            percent: completionPercentage,
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
                "Reducción semanal: ${currentWeek.completionPercentage.toInt()}%",
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${currentWeek.totalSmoked} fumados",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart(ProgressProvider provider) {
    final weeklyData = provider.weeklyProgress;
    final totals = weeklyData.reversed.map((w) => w.totalSmoked).toList();
    final labels = weeklyData.reversed
        .map((w) {
          final start = w.weekStart;
          return '${start.day}/${start.month}';
        })
        .toList();

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
          _buildSectionHeader(title: "Tendencia semanal", icon: FontAwesomeIcons.chartLine),
          const SizedBox(height: 20),
          TrendLineChart(weeklyTotals: totals, labels: labels),
        ],
      ),
    );
  }

  Widget _buildAchievements(ProgressProvider provider) {
    final gamification = Provider.of<GamificationProvider>(context);
    final achievements = gamification.dynamicAchievements;
    final totalCount = achievements.length;

    final sorted = List<DynamicAchievement>.from(achievements)
      ..sort((a, b) {
        if (a.unlocked && !b.unlocked) return -1;
        if (!a.unlocked && b.unlocked) return 1;
        return b.progressPercentage.compareTo(a.progressPercentage);
      });

    final displayList = sorted.take(3).toList();
    final unlockedCount = achievements.where((a) => a.unlocked).length;

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
              _buildSectionHeader(title: "Tus logros", icon: FontAwesomeIcons.trophy),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$unlockedCount/$totalCount",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (achievements.isEmpty)
            Text(
              "Aún no hay logros disponibles",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            )
          else
            ...displayList.map((a) => _buildDynamicAchievementItem(a)).toList(),
        ],
      ),
    );
  }

  Widget _buildDynamicAchievementItem(DynamicAchievement a) {
    final color = Color(int.parse(a.color.replaceAll('#', 'FF'), radix: 16));
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: a.unlocked ? color.withOpacity(0.15) : AppColors.tertiary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: a.unlocked ? color.withOpacity(0.3) : AppColors.tertiary,
                width: 1,
              ),
            ),
            child: Icon(
              Icons.emoji_events,
              color: a.unlocked ? color : AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: a.unlocked ? AppColors.text : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  a.unlocked ? "Completado" : "En progreso (${a.progressPercentage}%)",
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                if (!a.unlocked) ...[
                  const SizedBox(height: 8),
                  LinearPercentIndicator(
                    lineHeight: 6.0,
                    percent: a.progress.clamp(0.0, 1.0),
                    backgroundColor: AppColors.tertiary.withOpacity(0.5),
                    progressColor: color,
                    barRadius: const Radius.circular(10),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ],
            ),
          ),
          if (a.unlocked)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.check, color: AppColors.success, size: 16),
            ),
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
              color: isCompleted ? color.withOpacity(0.15) : AppColors.tertiary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCompleted ? color.withOpacity(0.3) : AppColors.tertiary,
                width: 1,
              ),
            ),
            child: Icon(icon, color: color, size: 20),
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
                    color: isCompleted ? AppColors.text : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                if (progress != null) ...[
                  const SizedBox(height: 8),
                  LinearPercentIndicator(
                    lineHeight: 6.0,
                    percent: progress.clamp(0.0, 1.0).toDouble(),
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
              child: const Icon(Icons.check, color: AppColors.success, size: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildEmotionAnalysis() {
    final realEmotions = Provider.of<ProgressProvider>(context).userProgress?.emotionStats ?? [];
    final List<EmotionChartData> chartData;
    if (realEmotions.isNotEmpty) {
      chartData = realEmotions.map((e) => EmotionChartData(
        label: _formatStatName((e['name'] ?? '').toString()),
        count: ((e['count'] as num?)?.toInt() ?? 0),
        color: AppColors.primary,
      )).toList();
    } else {
      chartData = const [
        EmotionChartData(label: 'Estrés', count: 12, color: Color(0xFFF08A84)),
        EmotionChartData(label: 'Ansiedad', count: 8, color: Color(0xFFF6C667)),
        EmotionChartData(label: 'Aburrimiento', count: 5, color: Color(0xFFA9C5D3)),
        EmotionChartData(label: 'Tristeza', count: 3, color: Color(0xFF4F6F52)),
      ];
    }

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
          EmotionPieChart(data: chartData),
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
    final realSymptoms = Provider.of<ProgressProvider>(context).userProgress?.symptomStats ?? [];
    final List<SymptomChartData> chartData;
    if (realSymptoms.isNotEmpty) {
      chartData = realSymptoms.map((e) => SymptomChartData(
        label: _formatStatName((e['name'] ?? '').toString()),
        count: ((e['count'] as num?)?.toInt() ?? 0),
        color: AppColors.primary,
      )).toList();
    } else {
      chartData = const [
        SymptomChartData(label: 'Tos', count: 10, color: Color(0xFF6DC9A1)),
        SymptomChartData(label: 'Dif. respirar', count: 7, color: Color(0xFFA9C5D3)),
        SymptomChartData(label: 'Antojos', count: 15, color: Color(0xFFF08A84)),
        SymptomChartData(label: 'Irritabilidad', count: 8, color: Color(0xFFF6C667)),
      ];
    }

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
          SymptomBarChart(data: chartData),
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

  String _formatStatName(String value) {
    if (value.isEmpty) return "Sin dato";
    return value
        .split(' ')
        .map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
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
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.text),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
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
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
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
                Icon(Icons.info_outline, color: AppColors.textSecondary, size: 32),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
