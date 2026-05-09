import 'package:flutter/material.dart';
import '../models/user_progress.dart';
import '../models/initial_test.dart';
import '../models/daily_plan.dart';
import '../models/daily_checkin.dart';
import '../models/smoking_record.dart';
import '../services/progress_service.dart';

class ProgressProvider extends ChangeNotifier {
  final ProgressService _progressService;
  
  UserProgress? _userProgress;
  DailyPlan? _dailyPlan;
  DailyCheckIn? _todayCheckIn;
  List<WeeklyProgress> _weeklyProgress = [];
  List<Achievement> _achievements = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _needsInitialTest = false;

  ProgressProvider(this._progressService);

  // Getters
  UserProgress? get userProgress => _userProgress;
  DailyPlan? get dailyPlan => _dailyPlan;
  DailyCheckIn? get todayCheckIn => _todayCheckIn;
  List<WeeklyProgress> get weeklyProgress => _weeklyProgress;
  List<Achievement> get achievements => _achievements;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get needsInitialTest => _needsInitialTest;

  void clear() {
    _userProgress = null;
    _dailyPlan = null;
    _todayCheckIn = null;
    _weeklyProgress = [];
    _achievements = [];
    _isLoading = false;
    _errorMessage = '';
    _needsInitialTest = false;
    notifyListeners();
  }

  // Inicializar el provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await getUserProgress();
      // si ya existe progreso, también cargamos el plan diario inmediatamente
      if (!_needsInitialTest) {
        await getDailyPlan();
      }
      await getWeeklyProgress();
      await getAchievements();
      await getTodayDailyCheckIn();
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

  Future<void> loadTodayDailyCheckIn() async {
    await getTodayDailyCheckIn();
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
          final data = response['data'];
          if (data is List) {
            _weeklyProgress = data
                .map<WeeklyProgress>((x) => WeeklyProgress.fromJson(Map<String, dynamic>.from(x)))
                .toList();
          } else if (data is Map) {
            _weeklyProgress = [WeeklyProgress.fromJson(Map<String, dynamic>.from(data))];
          } else {
            _weeklyProgress = [];
          }
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
          final data = Map<String, dynamic>.from(response['data']);
          data.forEach((key, value) {
            if (value is! Map) return;
            final achievement = Map<String, dynamic>.from(value);
            _achievements.add(Achievement(
              id: key,
              title: achievement['title'] ?? '',
              description: achievement['description'] ?? '',
              date: achievement['date'] != null ? DateTime.tryParse(achievement['date']) : null,
              isCompleted: achievement['completed'] ?? false,
              progress: _toDouble(achievement['progress']),
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

  Future<void> getTodayDailyCheckIn() async {
    try {
      final response = await _progressService.getTodayDailyCheckIn();
      if (response['success'] && response['data'] != null) {
        _todayCheckIn = DailyCheckIn.fromJson(Map<String, dynamic>.from(response['data']));
      } else {
        _todayCheckIn = null;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> saveDailyCheckIn(DailyCheckIn checkIn) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _progressService.saveDailyCheckIn(checkIn);
      if (response['success']) {
        final data = response['data'];
        if (data is Map && data['checkin'] != null) {
          _todayCheckIn = DailyCheckIn.fromJson(Map<String, dynamic>.from(data['checkin']));
        }
        if (data is Map && data['progress'] != null) {
          _userProgress = UserProgress.fromJson(Map<String, dynamic>.from(data['progress']));
        } else {
          await getUserProgress();
        }
        await getWeeklyProgress();
        await getAchievements();
        return true;
      }
      _errorMessage = response['message'];
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
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
        final data = response['data'];
        if (data is Map && data['progress'] != null) {
          _userProgress = UserProgress.fromJson(Map<String, dynamic>.from(data['progress']));
        }
        await getAchievements();
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
        await getAchievements();
        await getTodayDailyCheckIn();
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

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}
