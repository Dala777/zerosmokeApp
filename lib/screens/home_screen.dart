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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int cigarettesSmoked = 0;
  late AnimationController _controller;
  late Animation<double> _animation;
  
  final List<String> _quotes = [
    "Cada cigarro que no fumas es un paso hacia una vida más larga y saludable.",
    "No se trata de cuántas veces caes, sino de cuántas te levantas.",
    "Tu futuro empieza hoy. Decide ser libre del tabaco.",
    "Los pulmones limpios saben mejor que cualquier cigarro.",
    "Cada día sin fumar es una victoria para tu salud.",
  ];

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
    
    // Cargar progreso del usuario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
      progressProvider.loadUserProgress();
      progressProvider.loadDailyPlan();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String getRandomQuote() {
    _quotes.shuffle();
    return _quotes.first;
  }

  void _logCigarette(SmokingRecord record) {
    HapticFeedback.mediumImpact();
    setState(() {
      cigarettesSmoked++;
    });
    _controller.reset();
    _controller.forward();
    
    // Guardar el registro en la base de datos
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
    progressProvider.saveSmokingRecord(record);
  }

  void _showAdviceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Get safe area to ensure dialog fits properly
        final safeAreaPadding = MediaQuery.of(context).padding;
        final safeHeight = MediaQuery.of(context).size.height - 
                          safeAreaPadding.top - 
                          safeAreaPadding.bottom;
        
        return Dialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          // Add constraints to prevent overflow
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: safeHeight * 0.7, // 70% of safe height
            ),
            child: SingleChildScrollView( // Make scrollable if needed
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Take minimum space
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
                        const Text(
                          "Consejo del día", 
                          style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
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
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        getRandomQuote(), 
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "¡Entendido!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.health_and_safety, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Text(
              'Mi Progreso',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.text,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.accent),
              onPressed: () {},
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined, color: AppColors.accent),
              onPressed: () {},
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        // Add bottom padding to prevent overflow
        bottom: true,
        child: Consumer<ProgressProvider>(
          builder: (context, progressProvider, child) {
            // Si está cargando, mostrar indicador
            if (progressProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }
            
            // Si hay un error, mostrar mensaje
            if (progressProvider.errorMessage.isNotEmpty) {
              return Center(
                child: Text(
                  "Error: ${progressProvider.errorMessage}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            
            // Si el usuario necesita tomar el test inicial, mostrar mensaje
            if (progressProvider.needsInitialTest) {
              return const Center(
                child: Text("Por favor, completa el test inicial"),
              );
            }
            
            // Obtener datos del progreso
            final userProgress = progressProvider.userProgress;
            int daysWithoutSmoking = userProgress?.daysWithoutSmoking ?? 0;
            double moneySaved = userProgress?.moneySaved ?? 0.0;
            double healthProgress = userProgress?.healthProgress ?? 0.0;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0), // Add bottom padding
              child: ListView( // Use ListView instead of SingleChildScrollView
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                children: [
                  // Mensaje de motivación
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.2),
                          AppColors.tertiary.withOpacity(0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.emoji_emotions,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            "¡Hola! Recuerda que cada día sin fumar es una victoria. ¡Sigue así!",
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 16,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Widget de progreso
                  Card(
                    elevation: 4,
                    shadowColor: AppColors.accent.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ProgressWidget(
                        daysWithoutSmoking: daysWithoutSmoking,
                        moneySaved: moneySaved,
                        healthProgress: healthProgress,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Título de sección
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, bottom: 12.0),
                    child: Text(
                      "Acciones",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  
                  // Widget de consumo
                  Card(
                    elevation: 4,
                    shadowColor: AppColors.accent.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ConsumptionWidget(
                        onCigaretteLogged: (record) => _logCigarette(record),
                        onRequestAdvice: _showAdviceDialog,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Contador de cigarrillos
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_animation.value * 0.05),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.tertiary,
                                AppColors.primary.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      FontAwesomeIcons.smoking,
                                      color: AppColors.accent,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Text(
                                    "Cigarrillos registrados:",
                                    style: TextStyle(
                                      color: AppColors.text,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accent.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  "$cigarettesSmoked",
                                  style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
                  
                  const SizedBox(height: 24),
                  
                  // Botón de consejo
                  GestureDetector(
                    onTap: _showAdviceDialog,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.secondary.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lightbulb_outline,
                              color: AppColors.secondary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "¿Necesitas motivación?",
                                  style: TextStyle(
                                    color: AppColors.text,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Toca para un consejo motivador",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.secondary,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
