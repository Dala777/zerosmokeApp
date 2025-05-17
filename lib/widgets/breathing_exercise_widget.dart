import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../theme/app_colors.dart';

class BreathingExerciseWidget extends StatefulWidget {
  final VoidCallback onComplete;

  const BreathingExerciseWidget({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  _BreathingExerciseWidgetState createState() => _BreathingExerciseWidgetState();
}

class _BreathingExerciseWidgetState extends State<BreathingExerciseWidget>
    with TickerProviderStateMixin {
  bool _isExercising = false;
  int _currentCycle = 1;
  final int _totalCycles = 3;
  
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;
  
  String _currentAction = "Inhala";
  int _currentCount = 4;
  
  Timer? _countdownTimer;
  
  final Map<String, int> _breathingPattern = {
    "Inhala": 4,
    "Mantén": 7,
    "Exhala": 8,
  };
  
  int _currentPhaseIndex = 0;
  final List<String> _phases = ["Inhala", "Mantén", "Exhala"];

  @override
  void initState() {
    super.initState();
    
    _breathController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _breathAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startExercise() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isExercising = true;
      _currentCycle = 1;
      _currentPhaseIndex = 0;
      _currentAction = _phases[_currentPhaseIndex];
      _currentCount = _breathingPattern[_currentAction]!;
    });
    
    _startPhase();
  }

  void _startPhase() {
    // Configurar la animación según la fase
    if (_currentAction == "Inhala") {
      _breathController.duration = Duration(seconds: _breathingPattern[_currentAction]!);
      _breathController.forward(from: 0.0);
    } else if (_currentAction == "Mantén") {
      // Mantener el tamaño actual
      _breathController.stop();
    } else if (_currentAction == "Exhala") {
      _breathController.duration = Duration(seconds: _breathingPattern[_currentAction]!);
      _breathController.reverse(from: 1.0);
    }
    
    // Iniciar el contador
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentCount > 1) {
          _currentCount--;
        } else {
          // Pasar a la siguiente fase
          _currentPhaseIndex = (_currentPhaseIndex + 1) % _phases.length;
          _currentAction = _phases[_currentPhaseIndex];
          _currentCount = _breathingPattern[_currentAction]!;
          
          // Si completamos un ciclo
          if (_currentPhaseIndex == 0) {
            if (_currentCycle < _totalCycles) {
              _currentCycle++;
            } else {
              // Ejercicio completado
              _completeExercise();
              return;
            }
          }
          
          _startPhase();
        }
      });
    });
  }

  void _completeExercise() {
    _countdownTimer?.cancel();
    _breathController.stop();
    
    setState(() {
      _isExercising = false;
    });
    
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.air,
                color: Colors.blue.shade600,
                size: 24,
              ),
              const SizedBox(width: 10),
              const Text(
                "Respiración profunda",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "La respiración profunda puede ayudarte a relajarte y calmar tu mente cuando sientas el antojo de fumar.",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Círculo de respiración
          Center(
            child: AnimatedBuilder(
              animation: _breathAnimation,
              builder: (context, child) {
                return Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade100,
                    border: Border.all(
                      color: Colors.blue.shade300,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 100 * (_isExercising ? _breathAnimation.value : 0.7),
                      height: 100 * (_isExercising ? _breathAnimation.value : 0.7),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.shade400,
                      ),
                      child: Center(
                        child: Text(
                          _isExercising ? "$_currentCount" : "",
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Texto de acción actual
          Center(
            child: Text(
              _isExercising ? _currentAction : "",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Indicador de ciclo
          Center(
            child: Text(
              "Ciclo $_currentCycle de $_totalCycles",
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue.shade600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Botón de inicio
          if (!_isExercising)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _startExercise,
                icon: const Icon(Icons.play_arrow),
                label: const Text("Comenzar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          
          // Consejo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.shade100,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Consejo: Concéntrate en tu respiración y en las sensaciones de tu cuerpo. Esto te ayudará a calmar la ansiedad.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade800,
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
