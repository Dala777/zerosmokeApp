import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/progress_widgets.dart';
import '../widgets/consumption_widgets.dart';
import '../models/smoking_record.dart';
import '../providers/progress_provider.dart';
import '../widgets/emergency_button_widget.dart';
import '../widgets/zero_app_bar.dart';
import '../services/api_service.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _advice = '';
  bool _adviceLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
      progressProvider.loadUserProgress();
      progressProvider.loadDailyPlan();
      progressProvider.loadTodayRisk();
      _loadAdvice();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadAdvice() async {
    if (_advice.isNotEmpty) return;
    setState(() => _adviceLoading = true);
    final result = await ApiService.sendChatMessage(
      "Dame un consejo motivador breve y personalizado para alguien que esta dejando de fumar. Maximo 2 oraciones.",
    );
    if (!mounted) return;
    setState(() {
      _advice = result['success'] == true
          ? (result['reply'] ?? result['response'] ?? '').toString()
          : 'Cada dia sin fumar es una victoria. Respira profundo, toma agua y continua con tu plan.';
      _adviceLoading = false;
    });
  }

  void _logCigarette(SmokingRecord record) {
    HapticFeedback.mediumImpact();
    _controller.reset();
    _controller.forward();
    Provider.of<ProgressProvider>(context, listen: false).saveSmokingRecord(record);
  }

  Future<void> _showGroqAdvice() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text("Generando consejo personalizado...",
                style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );

    final result = await ApiService.sendChatMessage(
      "Dame un consejo motivador y personalizado basado en mi situacion actual para seguir adelante con mi proceso de dejar de fumar. Se breve, empatico y directo.",
    );

    if (!mounted) return;
    Navigator.of(context).pop();

    final reply = result['success'] == true
        ? (result['reply'] ?? result['response'] ?? '').toString()
        : 'Sigue adelante, cada dia sin fumar es una victoria. Respira profundo, toma agua y continua con tu plan.';

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lightbulb, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          "Consejo personalizado",
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.tertiary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      reply,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("¡Gracias!"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ZeroAppBar(
        title: 'Inicio',
        subtitle: 'Tu viaje hacia una vida sin humo',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.accent),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.accent),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: true,
        child: Consumer<ProgressProvider>(
          builder: (context, progressProvider, child) {
            if (progressProvider.isLoading && progressProvider.userProgress == null) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }

            if (progressProvider.needsInitialTest) {
              return const Center(
                child: Text("Por favor, completa el test inicial"),
              );
            }

            final userProgress = progressProvider.userProgress;
            int daysWithoutSmoking = userProgress?.daysWithoutSmoking ?? 0;
            double moneySaved = userProgress?.moneySaved ?? 0.0;
            double planProgress = userProgress?.planProgress ?? userProgress?.healthProgress ?? 0.0;
            int cigarettesAvoided = userProgress?.cigarettesAvoided ?? 0;
            final riskLevel = progressProvider.riskLevel;
            final riskScore = progressProvider.riskScore;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                children: [
                  // Indicador de riesgo
                  if (riskLevel.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _riskColor(riskLevel).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _riskColor(riskLevel).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(_riskIcon(riskLevel), color: _riskColor(riskLevel), size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Riesgo actual: ${riskLevel.toUpperCase()}",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: _riskColor(riskLevel), fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _riskMessage(riskLevel, riskScore),
                                  style: TextStyle(color: _riskColor(riskLevel).withOpacity(0.8), fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _riskColor(riskLevel).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text("$riskScore%", style: TextStyle(fontWeight: FontWeight.bold, color: _riskColor(riskLevel), fontSize: 14)),
                          ),
                        ],
                      ),
                    ),

                  // Consejo AI personalizado (reemplaza la card de motivación estática)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary.withOpacity(0.2), AppColors.tertiary.withOpacity(0.3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), shape: BoxShape.circle),
                          child: Icon(
                            _adviceLoading ? Icons.hourglass_empty : Icons.auto_awesome,
                            color: AppColors.primary, size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _adviceLoading
                              ? const Text(
                                  "Generando consejo personalizado...",
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontStyle: FontStyle.italic),
                                )
                              : Text(
                                  _advice,
                                  style: const TextStyle(color: AppColors.text, fontSize: 15, height: 1.4, fontWeight: FontWeight.w500),
                                ),
                        ),
                      ],
                    ),
                  ),

                  // Progreso: días, dinero, plan
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ProgressWidget(
                        daysWithoutSmoking: daysWithoutSmoking,
                        moneySaved: moneySaved,
                        planProgress: planProgress,
                        planCurrentDay: userProgress?.planCurrentDay ?? 0,
                        planTotalDays: userProgress?.planTotalDays ?? 0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Consumo: registrar cigarro / pedir consejo
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ConsumptionWidget(
                        onCigaretteLogged: (record) => _logCigarette(record),
                        onRequestAdvice: _showGroqAdvice,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Contador: fumados hoy + evitados
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_animation.value * 0.05),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.tertiary, AppColors.primary.withOpacity(0.7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                                        child: const Icon(FontAwesomeIcons.smoking, color: AppColors.accent, size: 18),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text("Hoy fumados:", style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(16)),
                                    child: Text(
                                      "${userProgress?.cigarettesSmokedToday ?? 0}",
                                      style: const TextStyle(color: AppColors.accent, fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                                        child: const Icon(Icons.block, color: AppColors.accent, size: 18),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text("Evitados:", style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(16)),
                                    child: Text(
                                      "$cigarettesAvoided",
                                      style: const TextStyle(color: AppColors.accent, fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Botón de emergencia
                  const EmergencyButtonWidget(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Helpers de riesgo
  Color _riskColor(String level) {
    switch (level.toLowerCase()) {
      case 'bajo':
        return AppColors.riskLow;
      case 'moderado':
        return AppColors.riskModerate;
      case 'alto':
        return AppColors.riskHigh;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _riskIcon(String level) {
    switch (level.toLowerCase()) {
      case 'bajo':
        return Icons.check_circle_outline;
      case 'moderado':
        return Icons.warning_amber_rounded;
      case 'alto':
        return Icons.error_outline;
      default:
        return Icons.info_outline;
    }
  }

  String _riskMessage(String level, int score) {
    switch (level.toLowerCase()) {
      case 'bajo':
        return 'Estás en control. Sigue aplicando tus estrategias.';
      case 'moderado':
        return 'Ten cuidado. Usa tus herramientas de afrontamiento.';
      case 'alto':
        return 'Alto riesgo de recaída. Busca apoyo ahora.';
      default:
        return 'Monitoreando tu riesgo personalizado.';
    }
  }
}
