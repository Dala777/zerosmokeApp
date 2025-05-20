import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../services/api_service.dart';

class AchievementProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Achievement> _achievements = [];
  bool _isLoading = false;
  String? _error;

  AchievementProvider(this._apiService);

  List<Achievement> get achievements => _achievements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Achievement> get unlockedAchievements => 
      _achievements.where((achievement) => achievement.isUnlocked).toList();

  List<Achievement> get inProgressAchievements => 
      _achievements.where((achievement) => !achievement.isUnlocked && achievement.progressCurrent > 0).toList();

  List<Achievement> get lockedAchievements => 
      _achievements.where((achievement) => !achievement.isUnlocked && achievement.progressCurrent == 0).toList();

  List<Achievement> get recentAchievements {
    final unlocked = unlockedAchievements;
    unlocked.sort((a, b) => (b.unlockedAt ?? DateTime.now()).compareTo(a.unlockedAt ?? DateTime.now()));
    return unlocked.take(5).toList();
  }

  Map<String, List<Achievement>> get achievementsByCategory {
    final result = <String, List<Achievement>>{};
    
    for (var achievement in _achievements) {
      if (!result.containsKey(achievement.category)) {
        result[achievement.category] = [];
      }
      result[achievement.category]!.add(achievement);
    }
    
    return result;
  }

  Future<void> fetchAchievements(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 1));
      
      // In a real app, this would be:
      // final achievements = await _apiService.getAchievements(userId);
      
      // For now, we'll use mock data
      _achievements = _generateMockAchievements();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<Achievement?> updateAchievementProgress(String achievementId, int progress) async {
    try {
      final index = _achievements.indexWhere((a) => a.id == achievementId);
      if (index == -1) return null;
      
      final achievement = _achievements[index];
      final newProgress = achievement.progressCurrent + progress;
      final isNowUnlocked = newProgress >= achievement.progressTotal && !achievement.isUnlocked;
      
      // Create updated achievement
      final updatedAchievement = Achievement(
        id: achievement.id,
        title: achievement.title,
        description: achievement.description,
        iconName: achievement.iconName,
        isUnlocked: isNowUnlocked || achievement.isUnlocked,
        unlockedAt: isNowUnlocked ? DateTime.now() : achievement.unlockedAt,
        progressCurrent: newProgress > achievement.progressTotal ? achievement.progressTotal : newProgress,
        progressTotal: achievement.progressTotal,
        category: achievement.category,
      );
      
      // Simulate API call
      await Future.delayed(Duration(milliseconds: 300));
      
      // In a real app, this would be:
      // await _apiService.updateAchievement(updatedAchievement);
      
      // Update local state
      _achievements[index] = updatedAchievement;
      notifyListeners();
      
      return isNowUnlocked ? updatedAchievement : null;
    } catch (e) {
      print('Error updating achievement: $e');
      return null;
    }
  }

  // Helper method to generate mock data
  List<Achievement> _generateMockAchievements() {
    return [
      // Tiempo sin fumar
      Achievement(
        id: 'time_1',
        title: '24 Horas Sin Fumar',
        description: 'Has completado tu primer día sin fumar. ¡Un gran paso!',
        iconName: 'access_time',
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(Duration(days: 5)),
        progressCurrent: 1,
        progressTotal: 1,
        category: 'Tiempo',
      ),
      Achievement(
        id: 'time_2',
        title: '3 Días Sin Fumar',
        description: 'Has estado 3 días sin fumar. Tu cuerpo está comenzando a recuperarse.',
        iconName: 'calendar_today',
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(Duration(days: 3)),
        progressCurrent: 3,
        progressTotal: 3,
        category: 'Tiempo',
      ),
      Achievement(
        id: 'time_3',
        title: '1 Semana Sin Fumar',
        description: 'Una semana completa sin fumar. ¡Tu sentido del gusto y olfato están mejorando!',
        iconName: 'event_available',
        isUnlocked: false,
        progressCurrent: 5,
        progressTotal: 7,
        category: 'Tiempo',
      ),
      Achievement(
        id: 'time_4',
        title: '2 Semanas Sin Fumar',
        description: 'Dos semanas sin fumar. Tu circulación está mejorando significativamente.',
        iconName: 'date_range',
        isUnlocked: false,
        progressCurrent: 0,
        progressTotal: 14,
        category: 'Tiempo',
      ),
      Achievement(
        id: 'time_5',
        title: '1 Mes Sin Fumar',
        description: 'Un mes completo sin fumar. Tu función pulmonar está mejorando notablemente.',
        iconName: 'event_note',
        isUnlocked: false,
        progressCurrent: 0,
        progressTotal: 30,
        category: 'Tiempo',
      ),
      
      // Cigarrillos no fumados
      Achievement(
        id: 'cig_1',
        title: '50 Cigarrillos Evitados',
        description: 'Has evitado fumar 50 cigarrillos desde que comenzaste.',
        iconName: 'smoke_free',
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(Duration(days: 2)),
        progressCurrent: 50,
        progressTotal: 50,
        category: 'Cigarrillos',
      ),
      Achievement(
        id: 'cig_2',
        title: '100 Cigarrillos Evitados',
        description: 'Has evitado fumar 100 cigarrillos. ¡Tus pulmones te lo agradecen!',
        iconName: 'smoke_free',
        isUnlocked: false,
        progressCurrent: 78,
        progressTotal: 100,
        category: 'Cigarrillos',
      ),
      Achievement(
        id: 'cig_3',
        title: '500 Cigarrillos Evitados',
        description: 'Has evitado fumar 500 cigarrillos. ¡Un logro impresionante!',
        iconName: 'smoke_free',
        isUnlocked: false,
        progressCurrent: 78,
        progressTotal: 500,
        category: 'Cigarrillos',
      ),
      
      // Dinero ahorrado
      Achievement(
        id: 'money_1',
        title: '50€ Ahorrados',
        description: 'Has ahorrado 50€ al no comprar cigarrillos.',
        iconName: 'savings',
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(Duration(days: 1)),
        progressCurrent: 50,
        progressTotal: 50,
        category: 'Ahorro',
      ),
      Achievement(
        id: 'money_2',
        title: '100€ Ahorrados',
        description: 'Has ahorrado 100€. ¡Piensa en lo que podrías comprar con ese dinero!',
        iconName: 'savings',
        isUnlocked: false,
        progressCurrent: 78,
        progressTotal: 100,
        category: 'Ahorro',
      ),
      Achievement(
        id: 'money_3',
        title: '500€ Ahorrados',
        description: 'Has ahorrado 500€. ¡Una cantidad significativa para gastar en algo que realmente disfrutes!',
        iconName: 'savings',
        isUnlocked: false,
        progressCurrent: 78,
        progressTotal: 500,
        category: 'Ahorro',
      ),
      
      // Ejercicios
      Achievement(
        id: 'exercise_1',
        title: '5 Ejercicios de Respiración',
        description: 'Has completado 5 ejercicios de respiración para controlar la ansiedad.',
        iconName: 'air',
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(Duration(hours: 12)),
        progressCurrent: 5,
        progressTotal: 5,
        category: 'Ejercicios',
      ),
      Achievement(
        id: 'exercise_2',
        title: '10 Caminatas Completadas',
        description: 'Has completado 10 caminatas para distraerte de los antojos.',
        iconName: 'directions_walk',
        isUnlocked: false,
        progressCurrent: 7,
        progressTotal: 10,
        category: 'Ejercicios',
      ),
      
      // Salud
      Achievement(
        id: 'health_1',
        title: 'Presión Arterial Normalizada',
        description: 'Tu presión arterial ha vuelto a niveles normales después de dejar de fumar.',
        iconName: 'favorite',
        isUnlocked: false,
        progressCurrent: 0,
        progressTotal: 1,
        category: 'Salud',
      ),
      Achievement(
        id: 'health_2',
        title: 'Mejora en Capacidad Pulmonar',
        description: 'Tu capacidad pulmonar ha mejorado significativamente desde que dejaste de fumar.',
        iconName: 'lungs',
        isUnlocked: false,
        progressCurrent: 0,
        progressTotal: 1,
        category: 'Salud',
      ),
      
      // Sociales
      Achievement(
        id: 'social_1',
        title: 'Compartir Tu Progreso',
        description: 'Has compartido tu progreso con amigos o en redes sociales.',
        iconName: 'share',
        isUnlocked: false,
        progressCurrent: 0,
        progressTotal: 1,
        category: 'Social',
      ),
      Achievement(
        id: 'social_2',
        title: 'Inspirar a un Amigo',
        description: 'Has inspirado a un amigo a comenzar su propio viaje para dejar de fumar.',
        iconName: 'people',
        isUnlocked: false,
        progressCurrent: 0,
        progressTotal: 1,
        category: 'Social',
      ),
    ];
  }
}
