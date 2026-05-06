import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/daily_checkin.dart';
import '../theme/app_colors.dart';

class DailyCheckInWidget extends StatefulWidget {
  final Function(DailyCheckIn) onSubmit;
  final bool isModal;

  const DailyCheckInWidget({
    Key? key,
    required this.onSubmit,
    this.isModal = false,
  }) : super(key: key);

  @override
  State<DailyCheckInWidget> createState() => _DailyCheckInWidgetState();
}

class _DailyCheckInWidgetState extends State<DailyCheckInWidget> {
  late String _selectedMood = 'normal';
  late int _cravingLevel = 2;
  late bool _smokedToday = false;
  late Set<String> _selectedSymptoms = {};
  late TextEditingController _noteController;
  late bool _showSymptomSelector = false;

  final List<String> _moods = ['excelente', 'bueno', 'normal', 'triste', 'terrible'];
  final List<String> _symptoms = [
    'Dolor de cabeza',
    'Ansiedad',
    'Insomnio',
    'Irritabilidad',
    'Fatiga',
    'Hambre',
  ];

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submitCheckIn() {
    final checkIn = DailyCheckIn(
      id: const Uuid().v4(),
      date: DateTime.now(),
      mood: _selectedMood,
      cravingLevel: _cravingLevel,
      smokedToday: _smokedToday,
      physicalSymptoms: _selectedSymptoms.toList(),
      note: _noteController.text.isEmpty ? null : _noteController.text,
      createdAt: DateTime.now(),
    );

    widget.onSubmit(checkIn);

    if (widget.isModal && mounted) {
      Navigator.of(context).pop();
    }
  }

  bool _isFormComplete() {
    return _selectedMood.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título
            if (widget.isModal)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Check-in Diario',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completa tu check-in diario para un mejor seguimiento',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

            // Sección 1: Estado Emocional (OBLIGATORIO)
            _buildSection(
              title: 'Tu Estado Emocional',
              required: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _moods.map((mood) {
                        final isSelected = _selectedMood == mood;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMood = mood;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DailyCheckIn.getMoodEmoji(mood),
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  DailyCheckIn.getMoodLabel(mood),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sección 2: Nivel de Antojo (OBLIGATORIO)
            _buildSection(
              title: 'Nivel de Antojo',
              required: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Slider(
                        value: _cravingLevel.toDouble(),
                        min: 0,
                        max: 5,
                        divisions: 5,
                        onChanged: (value) {
                          setState(() {
                            _cravingLevel = value.toInt();
                          });
                        },
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.primary.withOpacity(0.2),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Sin antojo',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$_cravingLevel/5',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Text(
                            'Muy fuerte',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sección 3: ¿Fumaste Hoy? (OBLIGATORIO)
            _buildSection(
              title: '¿Fumaste hoy?',
              required: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _smokedToday = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: !_smokedToday
                                  ? AppColors.primary
                                  : AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: !_smokedToday
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'No',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: !_smokedToday
                                        ? Colors.white
                                        : AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _smokedToday = true;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: _smokedToday
                                  ? Color(0xFFE74C3C)
                                  : AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.close_outlined,
                                  color: _smokedToday
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Sí',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _smokedToday
                                        ? Colors.white
                                        : AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sección 4: Síntomas Físicos (OPCIONAL)
            _buildSection(
              title: 'Síntomas Físicos',
              required: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showSymptomSelector = !_showSymptomSelector;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedSymptoms.isEmpty
                                ? 'Selecciona síntomas'
                                : '${_selectedSymptoms.length} síntoma(s)',
                            style: TextStyle(
                              fontSize: 14,
                              color: _selectedSymptoms.isEmpty
                                  ? AppColors.textSecondary
                                  : AppColors.text,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            _showSymptomSelector
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showSymptomSelector) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _symptoms.map((symptom) {
                        final isSelected = _selectedSymptoms.contains(symptom);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedSymptoms.remove(symptom);
                              } else {
                                _selectedSymptoms.add(symptom);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              symptom,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.text,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sección 5: Nota Personal (OPCIONAL)
            _buildSection(
              title: 'Nota Personal',
              required: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Escribe algo que desees recordar...',
                      hintStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.primary.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Botón Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isFormComplete() ? _submitCheckIn : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Guardar Check-in',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required bool required,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: Color(0xFFE74C3C),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
