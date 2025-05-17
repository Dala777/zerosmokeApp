import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import 'breathing_exercise_widget.dart';
import 'distraction_game_widget.dart';
import 'drink_water_widget.dart';
import 'walking_exercise_widget.dart';
import 'motivational_quotes_widget.dart';

class CopingTechniquesWidget extends StatefulWidget {
  const CopingTechniquesWidget({Key? key}) : super(key: key);

  @override
  _CopingTechniquesWidgetState createState() => _CopingTechniquesWidgetState();
}

class _CopingTechniquesWidgetState extends State<CopingTechniquesWidget> {
  String? _selectedTechnique;
  bool _showCompletionMessage = false;

  final Map<String, Map<String, dynamic>> _techniques = {
    'breathing': {
      'title': 'Respiración profunda',
      'subtitle': 'Técnica de respiración para reducir la ansiedad',
      'icon': Icons.air,
      'color': Colors.blue,
      'widget': null,
    },
    'game': {
      'title': 'Distráete con un juego',
      'subtitle': 'Un juego rápido para distraer tu mente',
      'icon': Icons.games,
      'color': Colors.purple,
      'widget': null,
    },
    'water': {
      'title': 'Bebe agua',
      'subtitle': 'Beber agua puede reducir el antojo',
      'icon': Icons.water_drop,
      'color': Colors.blue,
      'widget': null,
    },
    'walking': {
      'title': 'Camina 5 minutos',
      'subtitle': 'Caminar reduce la ansiedad y distrae la mente',
      'icon': Icons.directions_walk,
      'color': Colors.green,
      'widget': null,
    },
    'quotes': {
      'title': 'Frases motivadoras',
      'subtitle': 'Lee frases que te ayudarán a resistir',
      'icon': Icons.format_quote,
      'color': Colors.amber,
      'widget': null,
    },
  };

  void _onTechniqueComplete() {
    HapticFeedback.mediumImpact();
    setState(() {
      _showCompletionMessage = true;
    });
    
    // Ocultar el mensaje después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showCompletionMessage = false;
          _selectedTechnique = null;
        });
      }
    });
  }

  Widget _getTechniqueWidget(String technique) {
    switch (technique) {
      case 'breathing':
        return BreathingExerciseWidget(onComplete: _onTechniqueComplete);
      case 'game':
        return DistractionGameWidget(onComplete: _onTechniqueComplete);
      case 'water':
        return DrinkWaterWidget(onComplete: _onTechniqueComplete);
      case 'walking':
        return WalkingExerciseWidget(onComplete: _onTechniqueComplete);
      case 'quotes':
        return MotivationalQuotesWidget(onComplete: _onTechniqueComplete);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            "Técnicas para superar el antojo",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        ),
        
        if (_selectedTechnique == null)
          // Envolver ListView en un ConstrainedBox con altura fija
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4, // Reducido de 0.5 a 0.4
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _techniques.keys.map((technique) {
                  final data = _techniques[technique]!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: _buildTechniqueCard(technique, data),
                  );
                }).toList(),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_showCompletionMessage)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.shade400,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "¡Excelente trabajo!",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Has completado esta técnica con éxito. Sigue así para superar tus antojos.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              
              // Usar un ConstrainedBox con altura fija más pequeña
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4, // Reducido de 0.6 a 0.4
                ),
                child: SingleChildScrollView(
                  child: _getTechniqueWidget(_selectedTechnique!),
                ),
              ),
              
              // Asegurar que el botón de volver siempre sea visible
              Padding(
                padding: const EdgeInsets.only(top: 8.0), // Reducido de 16 a 8
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedTechnique = null;
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Volver a técnicas"),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

  Widget _buildTechniqueCard(String technique, Map<String, dynamic> data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            _selectedTechnique = technique;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: (data['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  data['icon'] as IconData,
                  color: data['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data['subtitle'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
