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

  // Inicializar el provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await getUserProgress();
      await getWeeklyProgress();
      await getAchievements();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar el progreso del usuario
  Future<void> loadUserProgress() async {
    await getUserProgress();
  }

  // Cargar el progreso semanal
  Future<void> loadWeeklyProgress() async {
    await getWeeklyProgress();
  }

  // Cargar los logros
  Future<void> loadAchievements() async {
    await getAchievements();
  }

  // Cargar el plan diario
  Future<void> loadDailyPlan() async {
    await getDailyPlan();
  }

  // Obtener el progreso del usuario
  Future<void> getUserProgress() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _progressService.getUserProgress();
      
      if (response['success']) {
        if (response['data'] != null) {
          _userProgress = UserProgress.fromJson(response['data']);
          _needsInitialTest = false;
        } else {
          _needsInitialTest = true;
        }
      } else {
        // Si el error es 404, significa que el usuario necesita hacer el test inicial
        if (response['message'].contains('No se encontró progreso')) {
          _needsInitialTest = true;
        } else {
          _errorMessage = response['message'];
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener el progreso semanal
  Future<void> getWeeklyProgress() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _progressService.getWeeklyProgress();
      
      if (response['success']) {
        if (response['data'] != null) {
          _weeklyProgress = List<WeeklyProgress>.from(
            response['data'].map((x) => WeeklyProgress.fromJson(x))
          );
        }
      } else {
        _errorMessage = response['message'];
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener los logros
  Future<void> getAchievements() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _progressService.getAchievements();
      
      if (response['success']) {
        if (response['data'] != null) {
          // Procesar los logros
          _achievements = [];
          response['data'].forEach((key, value) {
            _achievements.add(Achievement(
              id: key,
              title: value['title'] ?? '',
              description: value['description'] ?? '',
              date: value['date'] != null ? DateTime.parse(value['date']) : null,
              isCompleted: value['completed'] ?? false,
              progress: value['progress'] ?? 0.0,
            ));
          });
        }
      } else {
        _errorMessage = response['message'];
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Guardar el test inicial
  Future<bool> saveInitialTest(InitialTest test) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _progressService.saveInitialTest(test);
      
      if (response['success']) {
        _userProgress = UserProgress.fromJson(response['data']);
        _needsInitialTest = false;
        return true;
      } else {
        _errorMessage = response['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener el plan diario
  Future<void> getDailyPlan({DateTime? date}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _progressService.getDailyPlan(date: date);
      
      if (response['success']) {
        _dailyPlan = DailyPlan.fromJson(response['data']);
      } else {
        _errorMessage = response['message'];
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Completar una actividad
  Future<bool> completeActivity(String planId, String activityId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _progressService.completeActivity(planId, activityId);
      
      if (response['success']) {
        _dailyPlan = DailyPlan.fromJson(response['data']);
        return true;
      } else {
        _errorMessage = response['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Guardar registro de cigarrillo
  Future<bool> saveSmokingRecord(SmokingRecord record) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _progressService.saveSmokingRecord(record);
      
      if (response['success']) {
        // Actualizar el progreso del usuario después de registrar un cigarrillo
        await getUserProgress();
        await getWeeklyProgress();
        return true;
      } else {
        _errorMessage = response['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar el progreso del usuario
  Future<bool> updateUserProgress(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _progressService.updateUserProgress(data);
      
      if (response['success']) {
        _userProgress = UserProgress.fromJson(response['data']);
        return true;
      } else {
        _errorMessage = response['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
