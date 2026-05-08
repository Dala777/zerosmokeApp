import 'package:flutter/foundation.dart';
import '../models/cigarette_log.dart';
import '../services/api_service.dart';

class CigaretteLogProvider with ChangeNotifier {
  final ApiService _apiService;
  List<CigaretteLog> _logs = [];
  bool _isLoading = false;
  String? _error;

  CigaretteLogProvider(this._apiService);

  List<CigaretteLog> get logs => [..._logs];
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Obtener logs para un día específico
  List<CigaretteLog> getLogsForDay(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    return _logs.where((log) => 
      log.timestamp.isAfter(startOfDay) && 
      log.timestamp.isBefore(endOfDay)
    ).toList();
  }

  // Obtener logs para un rango de fechas
  List<CigaretteLog> getLogsForDateRange(DateTime start, DateTime end) {
    return _logs.where((log) => 
      log.timestamp.isAfter(start) && 
      log.timestamp.isBefore(end)
    ).toList();
  }

  // Obtener el total de cigarrillos por día
  Map<DateTime, int> getDailyCigaretteCounts(int days) {
    final result = <DateTime, int>{};
    final now = DateTime.now();
    
    for (int i = 0; i < days; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      final logsForDay = getLogsForDay(date);
      result[date] = logsForDay.length;
    }
    
    return result;
  }

  // Obtener las razones más comunes
  Map<String, int> getCommonReasons() {
    final result = <String, int>{};
    
    for (var log in _logs) {
      if (result.containsKey(log.reason)) {
        result[log.reason] = result[log.reason]! + 1;
      } else {
        result[log.reason] = 1;
      }
    }
    
    return result;
  }

  // Obtener las ubicaciones más comunes
  Map<String, int> getCommonLocations() {
    final result = <String, int>{};
    
    for (var log in _logs) {
      if (result.containsKey(log.location)) {
        result[log.location] = result[log.location]! + 1;
      } else {
        result[log.location] = 1;
      }
    }
    
    return result;
  }

  // Obtener los estados de ánimo más comunes
  Map<String, int> getCommonMoods() {
    final result = <String, int>{};
    
    for (var log in _logs) {
      if (result.containsKey(log.mood)) {
        result[log.mood] = result[log.mood]! + 1;
      } else {
        result[log.mood] = 1;
      }
    }
    
    return result;
  }

  Future<void> fetchLogs(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 1));
      
      // In a real app, this would be:
      // final logs = await _apiService.getCigaretteLogs(userId);
      
      // For now, we'll use mock data
      _logs = _generateMockLogs();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addLog(CigaretteLog log) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Simulate API call
      await Future.delayed(Duration(milliseconds: 500));
      
      // In a real app, this would be:
      // await _apiService.addCigaretteLog(log);
      
      // Add to local state
      _logs.add(log);
      _logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateLog(CigaretteLog log) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Simulate API call
      await Future.delayed(Duration(milliseconds: 500));
      
      // In a real app, this would be:
      // await _apiService.updateCigaretteLog(log);
      
      // Update local state
      final index = _logs.indexWhere((l) => l.id == log.id);
      if (index != -1) {
        _logs[index] = log;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteLog(String id) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Simulate API call
      await Future.delayed(Duration(milliseconds: 500));
      
      // In a real app, this would be:
      // await _apiService.deleteCigaretteLog(id);
      
      // Update local state
      _logs.removeWhere((log) => log.id == id);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Helper method to generate mock data
  List<CigaretteLog> _generateMockLogs() {
    final now = DateTime.now();
    final reasons = ['Estrés', 'Después de comer', 'Socializar', 'Aburrimiento', 'Ansiedad'];
    final locations = ['Casa', 'Trabajo', 'Bar', 'Calle', 'Coche'];
    final moods = ['Estresado', 'Ansioso', 'Relajado', 'Aburrido', 'Irritado'];
    final intensities = ['Baja', 'Media', 'Alta'];
    
    return List.generate(20, (index) {
      final daysAgo = index ~/ 3; // Distribuir los logs en los últimos días
      final hoursOffset = (index % 8) * 3; // Distribuir a lo largo del día
      
      return CigaretteLog(
        id: 'log_$index',
        timestamp: now.subtract(Duration(days: daysAgo, hours: hoursOffset)),
        reason: reasons[index % reasons.length],
        location: locations[index % locations.length],
        mood: moods[index % moods.length],
        intensity: intensities[index % intensities.length],
        notes: index % 3 == 0 ? 'Nota para el registro #$index' : '',
      );
    });
  }
}
