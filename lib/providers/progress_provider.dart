import 'package:flutter/material.dart';
import '../models/user_progress.dart';
import '../models/initial_test.dart';
import '../models/daily_plan.dart';
import '../models/smoking_record.dart';
import '../services/progress_service.dart';

class ProgressProvider extends ChangeNotifier {
  final ProgressService _progressService;
  
  UserProgress? _userProgress;
  DailyPlan? _dailyPlan;
  List<WeeklyProgress> _weeklyProgress = [];
  List<Achievement> _achievements = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _needsInitialTest = false;

  ProgressProvider(this._progressService);

  // Getters
  UserProgress? get userProgress => _userProgress;
  DailyPlan? get dailyPlan => _dailyPlan;
  List<WeeklyProgress> get weeklyProgress => _weeklyProgress;
  List<Achievement> get achievements => _achievements;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get needsInitialTest => _needsInitialTest;

  // Calcular puntaje de Fagerström
  int _calculateFagerstromScore(InitialTest test) {
    int score = 0;
    
    // Pregunta 1: ¿Cuántos cigarrillos fumas al día?
    if (test.cigarettesPerDay <= 10) {
      score += 0;
    } else if (test.cigarettesPerDay <= 20) {
      score += 1;
    } else if (test.cigarettesPerDay <= 30) {
      score += 2;
    } else {
      score += 3;
    }
    
    // Pregunta 2: ¿Fumas dentro de los primeros 30 minutos?
    if (test.smokesWithinMinutes) {
      score += 1;
    }
    
    // Pregunta 3: ¿Difícil evitar lugares prohibidos?
    if (test.difficultToAvoidPublicPlaces) {
      score += 1;
    }
    
    // Pregunta 4: ¿El cigarrillo de la mañana es el más difícil de abandonar?
    if (test.hatesMostToGiveUpMorningCigarette) {
      score += 1;
    }
    
    // Pregunta 5: ¿Fumas más en la mañana?
    if (test.smokesMoreInMorning) {
      score += 1;
    }
    
    // Pregunta 6: ¿Fumas cuando estás enfermo?
    if (test.smokesWhenIll) {
      score += 1;
    }
    
    return score;
  }

  // Método helper para manejar loading sin notificar durante build
  void _setLoading(bool loading) {
    _isLoading = loading;
    // Solo notificar si no estamos en el proceso de build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Inicializar el provider
  Future<void> initialize() async {
    _setLoading(true);

    try {
      await getUserProgress();
      await getWeeklyProgress();
      await getAchievements();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Métodos wrapper para compatibilidad con HomeScreen
  Future<void> loadUserProgress() async {
    await getUserProgress();
  }

  Future<void> loadDailyPlan() async {
    await getDailyPlan();
  }

  Future<void> loadWeeklyProgress() async {
    await getWeeklyProgress();
  }

  Future<void> loadAchievements() async {
    await getAchievements();
  }

  // Asignar plan basado en el test inicial
  Future<bool> assignPlan(InitialTest test) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      final fagerstromScore = _calculateFagerstromScore(test);
      
      final response = await _progressService.assignPlan(fagerstromScore);
      
      if (response['success'] == true) {
        // Actualizar el progreso del usuario después de asignar el plan
        await getUserProgress();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Error al asignar el plan';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Obtener el progreso del usuario
  Future<void> getUserProgress() async {
    _setLoading(true);
    _errorMessage = '';

    try {
      final response = await _progressService.getUserProgress();
      
      if (response['success'] == true) {
        if (response['data'] != null) {
          _userProgress = UserProgress.fromJson(response['data']);
          _needsInitialTest = false;
        } else {
          _needsInitialTest = true;
        }
      } else {
        // Si el error es 404, significa que el usuario necesita hacer el test inicial
        final message = response['message'] ?? '';
        if (message.contains('No se encontró progreso')) {
          _needsInitialTest = true;
        } else {
          _errorMessage = message;
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Obtener el progreso semanal
  Future<void> getWeeklyProgress() async {
    _setLoading(true);
    _errorMessage = '';

    try {
      final response = await _progressService.getWeeklyProgress();
      
      if (response['success'] == true) {
        if (response['data'] != null) {
          // Crear una lista con el progreso semanal
          _weeklyProgress = [WeeklyProgress.fromJson(response['data'])];
        }
      } else {
        _errorMessage = response['message'] ?? 'Error al obtener progreso semanal';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Obtener los logros
  Future<void> getAchievements() async {
    _setLoading(true);
    _errorMessage = '';

    try {
      final response = await _progressService.getAchievements();
      
      if (response['success'] == true) {
        if (response['data'] != null) {
          // Procesar los logros
          _achievements = [];
          final achievementsData = response['data'] as Map<String, dynamic>;
          achievementsData.forEach((key, value) {
            _achievements.add(Achievement(
              id: key,
              title: value['title'] ?? '',
              description: value['description'] ?? '',
              date: value['date'] != null ? DateTime.parse(value['date']) : null,
              isCompleted: value['completed'] ?? false,
              progress: (value['progress'] ?? 0.0).toDouble(),
            ));
          });
        }
      } else {
        _errorMessage = response['message'] ?? 'Error al obtener logros';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Guardar el test inicial
  Future<bool> saveInitialTest(InitialTest test) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      final response = await _progressService.saveInitialTest(test);
      
      if (response['success'] == true) {
        _userProgress = UserProgress.fromJson(response['data']);
        _needsInitialTest = false;
        
        // Asignar plan después de guardar el test
        await assignPlan(test);
        
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Error al guardar test inicial';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Obtener el plan diario
  Future<void> getDailyPlan({DateTime? date}) async {
    // No usar _setLoading aquí para evitar setState durante build
    _isLoading = true;
    _errorMessage = '';

    try {
      final response = await _progressService.getDailyPlan(date: date);
      
      if (response['success'] == true && response['data'] != null) {
        _dailyPlan = DailyPlan.fromJson(response['data']);
      } else {
        _errorMessage = response['message'] ?? 'No hay plan disponible para esta fecha';
        _dailyPlan = null;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _dailyPlan = null;
    } finally {
      _isLoading = false;
      // Usar post frame callback para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Completar una actividad
  Future<bool> completeActivity(String planId, String activityId) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      final response = await _progressService.completeActivity(planId, activityId);
      
      if (response['success'] == true) {
        // Actualizar el plan diario con la nueva información
        if (response['data'] != null) {
          _dailyPlan = DailyPlan.fromJson(response['data']);
        }
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Error al completar la actividad';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Guardar registro de cigarrillo
  Future<bool> saveSmokingRecord(SmokingRecord record) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      final response = await _progressService.saveSmokingRecord(record);
      
      if (response['success'] == true) {
        // Actualizar el progreso del usuario después de registrar un cigarrillo
        await getUserProgress();
        await getWeeklyProgress();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Error al guardar registro';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar el progreso del usuario
  Future<bool> updateUserProgress(Map<String, dynamic> data) async {
    _setLoading(true);
    _errorMessage = '';

    try {
      final response = await _progressService.updateUserProgress(data);
      
      if (response['success'] == true) {
        _userProgress = UserProgress.fromJson(response['data']);
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Error al actualizar progreso';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
