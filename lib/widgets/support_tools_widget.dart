import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import 'breathing_exercise_widget.dart';
import 'distraction_game_widget.dart';
import 'drink_water_widget.dart';
import 'walking_exercise_widget.dart';
import 'motivational_quotes_widget.dart';

class SupportToolsWidget extends StatefulWidget {
  const SupportToolsWidget({Key? key}) : super(key: key);

  @override
  _SupportToolsWidgetState createState() => _SupportToolsWidgetState();
}

class _SupportToolsWidgetState extends State<SupportToolsWidget> {
  final List<Map<String, dynamic>> _tools = [
    {
      'id': 'breathing',
      'title': 'Respiración profunda',
      'description': 'Técnica de respiración para reducir la ansiedad',
      'icon': Icons.air,
      'color': Colors.blue,
    },
    {
      'id': 'game',
      'title': 'Distráete con un juego',
      'description': 'Un juego rápido para distraer tu mente',
      'icon': Icons.games,
      'color': Colors.purple,
    },
    {
      'id': 'water',
      'title': 'Bebe agua',
      'description': 'Beber agua puede reducir el antojo',
      'icon': Icons.water_drop,
      'color': Colors.blue,
    },
    {
      'id': 'walking',
      'title': 'Camina 5 minutos',
      'description': 'Caminar reduce la ansiedad y distrae la mente',
      'icon': Icons.directions_walk,
      'color': Colors.green,
    },
    {
      'id': 'quotes',
      'title': 'Frases motivadoras',
      'description': 'Lee frases que te ayudarán a resistir',
      'icon': Icons.format_quote,
      'color': Colors.amber,
    },
    {
      'id': 'diary',
      'title': 'Diario emocional',
      'description': 'Registra tus emociones y pensamientos',
      'icon': Icons.book,
      'color': Colors.indigo,
    },
    {
      'id': 'music',
      'title': 'Música relajante',
      'description': 'Escucha música para calmar tu mente',
      'icon': Icons.music_note,
      'color': Colors.pink,
    },
    {
      'id': 'chat',
      'title': 'Chat de apoyo',
      'description': 'Habla con nuestro asistente virtual',
      'icon': Icons.chat,
      'color': Colors.teal,
    },
  ];
  
  String? _selectedToolId;
  
  void _selectTool(String toolId) {
    setState(() {
      _selectedToolId = toolId;
    });
  }
  
  void _onToolComplete() {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedToolId = null;
    });
    
    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('¡Excelente trabajo! Has completado esta técnica con éxito.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
  
  Widget _getToolWidget(String toolId) {
    switch (toolId) {
      case 'breathing':
        return BreathingExerciseWidget(onComplete: _onToolComplete);
      case 'game':
        return DistractionGameWidget(onComplete: _onToolComplete);
      case 'water':
        return DrinkWaterWidget(onComplete: _onToolComplete);
      case 'walking':
        return WalkingExerciseWidget(onComplete: _onToolComplete);
      case 'quotes':
        return MotivationalQuotesWidget(onComplete: _onToolComplete);
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 64,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                "Esta herramienta estará disponible próximamente",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => setState(() => _selectedToolId = null),
                child: const Text("Volver"),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Herramientas de apoyo",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: _selectedToolId == null
          ? _buildToolsList()
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _getToolWidget(_selectedToolId!),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => setState(() => _selectedToolId = null),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Volver a herramientas"),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildToolsList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mensaje de introducción
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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Herramientas para superar antojos",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "Estas herramientas te ayudarán a superar los momentos difíciles y a mantener tu motivación para dejar de fumar.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Herramientas disponibles
          const Text(
            "Herramientas disponibles",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),
          
          // Grid de herramientas
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: _tools.length,
            itemBuilder: (context, index) {
              final tool = _tools[index];
              return _buildToolCard(tool);
            },
          ),
          
          const SizedBox(height: 24),
          
          // Consejo
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
                  "Los antojos de nicotina suelen durar solo unos minutos. Utiliza estas herramientas para distraer tu mente durante ese tiempo y verás cómo el antojo desaparece.",
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
    );
  }
  
  Widget _buildToolCard(Map<String, dynamic> tool) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _selectTool(tool['id']);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: tool['color'].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                tool['icon'],
                color: tool['color'],
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              tool['title'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                tool['description'],
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: tool['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified,
                    color: tool['color'],
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Validado",
                    style: TextStyle(
                      fontSize: 10,
                      color: tool['color'],
                      fontWeight: FontWeight.bold,
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
}
