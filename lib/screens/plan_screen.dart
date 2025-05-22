import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/progress_provider.dart';
import '../models/daily_plan.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({Key? key}) : super(key: key);

  @override
  _PlanScreenState createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadDailyPlan();
  }
  
  Future<void> _loadDailyPlan() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
      await progressProvider.getDailyPlan(date: _selectedDate);
    } catch (e) {
      print('Error cargando plan diario: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadDailyPlan();
  }
  
  Future<void> _completeActivity(String planId, String activityId) async {
    HapticFeedback.mediumImpact();
    
    try {
      final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
      await progressProvider.completeActivity(planId, activityId);
      
      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Actividad completada con éxito!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      // Mostrar mensaje de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Mi Plan ZeroSmoke",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Mostrar información sobre el plan
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Sobre tu Plan ZeroSmoke"),
                  content: const Text(
                    "Tu plan personalizado está diseñado según tu nivel de dependencia a la nicotina. Incluye actividades diarias para ayudarte a dejar de fumar de manera efectiva y sostenible.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Entendido"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProgressProvider>(
        builder: (context, progressProvider, child) {
          final dailyPlan = progressProvider.dailyPlan;
          final isLoading = progressProvider.isLoading || _isLoading;
          
          return Column(
            children: [
              // Calendario horizontal
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${_getMonthName(_selectedDate.month)} ${_selectedDate.year}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios, size: 16, color: Colors.white),
                                onPressed: () {
                                  _selectDate(_selectedDate.subtract(const Duration(days: 7)));
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                                onPressed: () {
                                  _selectDate(_selectedDate.add(const Duration(days: 7)));
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 14, // Mostrar 2 semanas
                        itemBuilder: (context, index) {
                          final date = DateTime.now().subtract(Duration(days: 7 - index));
                          final isSelected = date.year == _selectedDate.year &&
                                            date.month == _selectedDate.month &&
                                            date.day == _selectedDate.day;
                          final isToday = date.year == DateTime.now().year &&
                                         date.month == DateTime.now().month &&
                                         date.day == DateTime.now().day;
                          
                          return GestureDetector(
                            onTap: () => _selectDate(date),
                            child: Container(
                              width: 60,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                        ? AppColors.accent.withOpacity(0.3)
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: isToday && !isSelected
                                    ? Border.all(color: Colors.white)
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _getDayName(date.weekday),
                                    style: TextStyle(
                                      color: isSelected ? AppColors.primary : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.transparent,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${date.day}",
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // Contenido del plan diario
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : dailyPlan == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 64,
                                  color: AppColors.textSecondary.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "No hay plan disponible para esta fecha",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: _loadDailyPlan,
                                  child: const Text("Recargar"),
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Información del día
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary.withOpacity(0.7),
                                        AppColors.accent.withOpacity(0.7),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.2),
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
                                          Text(
                                            "Día ${dailyPlan.dayNumber}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              "${(dailyPlan.completionPercentage * 100).toInt()}% completado",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        dailyPlan.message.isNotEmpty
                                            ? dailyPlan.message
                                            : "Completa las actividades de hoy para avanzar en tu plan.",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: LinearProgressIndicator(
                                          value: dailyPlan.completionPercentage,
                                          minHeight: 8,
                                          backgroundColor: Colors.white.withOpacity(0.3),
                                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Lista de actividades
                                const Text(
                                  "Actividades de hoy",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                ...dailyPlan.activities.map((activity) => _buildActivityCard(
                                  activity,
                                  onComplete: () => _completeActivity(dailyPlan.id, activity.id),
                                )).toList(),
                                
                                const SizedBox(height: 24),
                                
                                // Consejo del día
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.tertiary.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.lightbulb,
                                              color: AppColors.primary,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            "Consejo del día",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.text,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        "Recuerda que cada día sin fumar es una victoria. Los antojos suelen durar solo unos minutos. Respira profundamente y recuerda por qué comenzaste este viaje.",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildActivityCard(Activity activity, {required VoidCallback onComplete}) {
    // Determinar el ícono según el tipo de actividad
    IconData activityIcon;
    Color activityColor;
    
    switch (activity.type) {
      case 'exercise':
        activityIcon = Icons.directions_run;
        activityColor = Colors.green;
        break;
      case 'breathing':
        activityIcon = Icons.air;
        activityColor = Colors.blue;
        break;
      case 'reflection':
        activityIcon = Icons.psychology;
        activityColor = Colors.purple;
        break;
      case 'social':
        activityIcon = Icons.people;
        activityColor = Colors.orange;
        break;
      default:
        activityIcon = Icons.check_circle;
        activityColor = AppColors.primary;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: activityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    activityIcon,
                    color: activityColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: activity.isCompleted
                              ? AppColors.textSecondary
                              : AppColors.text,
                          decoration: activity.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      Text(
                        "${activity.durationMinutes} minutos",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          decoration: activity.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                if (activity.isCompleted)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 20,
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: onComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: activityColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text("Completar"),
                  ),
              ],
            ),
            if (activity.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                activity.description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  decoration: activity.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified,
                        color: AppColors.accent,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Validado científicamente",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (!activity.isCompleted)
                  TextButton(
                    onPressed: () {
                      // Mostrar detalles de la actividad
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(activity.title),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(activity.description),
                              const SizedBox(height: 16),
                              const Text(
                                "Beneficios:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text("• Reduce la ansiedad y el estrés"),
                              const Text("• Mejora la concentración"),
                              const Text("• Disminuye los antojos de nicotina"),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cerrar"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                onComplete();
                              },
                              child: const Text("Completar"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text("Ver detalles"),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  String _getMonthName(int month) {
    const months = [
      "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
      "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
    ];
    return months[month - 1];
  }
  
  String _getDayName(int weekday) {
    const days = ["", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"];
    return days[weekday];
  }
}
