import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/emotional_entry.dart';

class EmotionalDiaryWidget extends StatefulWidget {
  final List<EmotionalEntry> entries;
  final Function(EmotionalEntry) onAddEntry;
  
  const EmotionalDiaryWidget({
    Key? key,
    required this.entries,
    required this.onAddEntry,
  }) : super(key: key);

  @override
  _EmotionalDiaryWidgetState createState() => _EmotionalDiaryWidgetState();
}

class _EmotionalDiaryWidgetState extends State<EmotionalDiaryWidget> {
  late TextEditingController _notesController;
  late TextEditingController _triggersController;
  String _selectedMood = 'neutro';
  int _selectedIntensity = 5;
  
  final Map<String, Map<String, dynamic>> _moodData = {
    'excelente': {
      'icon': Icons.sentiment_very_satisfied,
      'color': Color(0xFF6DC9A1),
      'label': 'Excelente'
    },
    'bueno': {
      'icon': Icons.sentiment_satisfied,
      'color': Color(0xFF9DC183),
      'label': 'Bueno'
    },
    'neutro': {
      'icon': Icons.sentiment_neutral,
      'color': AppColors.secondary,
      'label': 'Neutro'
    },
    'triste': {
      'icon': Icons.sentiment_dissatisfied,
      'color': Color(0xFFF6C667),
      'label': 'Triste'
    },
    'ansioso': {
      'icon': Icons.sentiment_very_dissatisfied,
      'color': Color(0xFFF08A84),
      'label': 'Ansioso'
    },
  };

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _triggersController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _triggersController.dispose();
    super.dispose();
  }

  void _addEntry() {
    if (_notesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, añade una nota a tu entrada'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final newEntry = EmotionalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'user1',
      date: DateTime.now(),
      mood: _selectedMood,
      intensity: _selectedIntensity,
      triggers: _triggersController.text.isNotEmpty ? _triggersController.text : null,
      notes: _notesController.text,
    );

    widget.onAddEntry(newEntry);
    
    _notesController.clear();
    _triggersController.clear();
    setState(() {
      _selectedMood = 'neutro';
      _selectedIntensity = 5;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Entrada guardada en tu diario emocional'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Formulario para nueva entrada
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.tertiary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Registra tu estado emocional',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Selector de emociones
                const Text(
                  '¿Cómo te sientes hoy?',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _moodData.entries.map((entry) {
                    final mood = entry.key;
                    final data = entry.value;
                    final isSelected = _selectedMood == mood;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMood = mood;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? data['color'] : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: data['color'],
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          data['icon'],
                          color: data['color'],
                          size: 28,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                
                // Intensidad del sentimiento
                const Text(
                  'Intensidad (1-10)',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _selectedIntensity.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.primary.withOpacity(0.2),
                        onChanged: (value) {
                          setState(() {
                            _selectedIntensity = value.toInt();
                          });
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _selectedIntensity.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Disparadores (triggers)
                TextField(
                  controller: _triggersController,
                  decoration: InputDecoration(
                    hintText: '¿Qué causó este sentimiento? (opcional)',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  maxLines: 2,
                  style: const TextStyle(color: AppColors.text),
                ),
                const SizedBox(height: 12),
                
                // Notas
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    hintText: 'Escribe una nota sobre cómo te sientes...',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  maxLines: 3,
                  style: const TextStyle(color: AppColors.text),
                ),
                const SizedBox(height: 16),
                
                // Botón de guardar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addEntry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Guardar entrada',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Historial de entradas
          const Text(
            'Mis entradas recientes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          
          if (widget.entries.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.book_outlined,
                      size: 48,
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay entradas aún',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...widget.entries.map((entry) {
              final moodData = _moodData[entry.mood]!;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: moodData['color'],
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          moodData['icon'],
                          color: moodData['color'],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                moodData['label'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.text,
                                ),
                              ),
                              Text(
                                _formatDate(entry.date),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: moodData['color'],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${entry.intensity}/10',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (entry.notes != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          entry.notes!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    if (entry.triggers != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Disparador: ${entry.triggers}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
