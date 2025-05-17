class UserProgress {
  final String userId;
  final DateTime startDate;
  final int cigarettesPerDay;
  final double packagePrice;
  final int cigarettesAvoided;
  final double moneySaved;
  final int daysWithoutSmoking;
  final double healthProgress;
  final String dependencyLevel;
  final List<String> motivations;
  final Map<String, dynamic> healthMetrics;
  final Map<String, dynamic> achievements;
  final List<WeeklyProgress> weeklyData;

  UserProgress({
    required this.userId,
    required this.startDate,
    required this.cigarettesPerDay,
    required this.packagePrice,
    this.cigarettesAvoided = 0,
    this.moneySaved = 0.0,
    this.daysWithoutSmoking = 0,
    this.healthProgress = 0.0,
    this.dependencyLevel = 'Moderado',
    this.motivations = const [],
    this.healthMetrics = const {},
    this.achievements = const {},
    this.weeklyData = const [],
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      userId: json['userId'] ?? '',
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate']) 
          : DateTime.now(),
      cigarettesPerDay: json['cigarettesPerDay'] ?? 0,
      packagePrice: (json['packagePrice'] ?? 0.0).toDouble(),
      cigarettesAvoided: json['cigarettesAvoided'] ?? 0,
      moneySaved: (json['moneySaved'] ?? 0.0).toDouble(),
      daysWithoutSmoking: json['daysWithoutSmoking'] ?? 0,
      healthProgress: (json['healthProgress'] ?? 0.0).toDouble(),
      dependencyLevel: json['dependencyLevel'] ?? 'Moderado',
      motivations: List<String>.from(json['motivations'] ?? []),
      healthMetrics: json['healthMetrics'] ?? {},
      achievements: json['achievements'] ?? {},
      weeklyData: json['weeklyData'] != null
          ? List<WeeklyProgress>.from(
              json['weeklyData'].map((x) => WeeklyProgress.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'startDate': startDate.toIso8601String(),
      'cigarettesPerDay': cigarettesPerDay,
      'packagePrice': packagePrice,
      'cigarettesAvoided': cigarettesAvoided,
      'moneySaved': moneySaved,
      'daysWithoutSmoking': daysWithoutSmoking,
      'healthProgress': healthProgress,
      'dependencyLevel': dependencyLevel,
      'motivations': motivations,
      'healthMetrics': healthMetrics,
      'achievements': achievements,
      'weeklyData': weeklyData.map((x) => x.toJson()).toList(),
    };
  }

  UserProgress copyWith({
    String? userId,
    DateTime? startDate,
    int? cigarettesPerDay,
    double? packagePrice,
    int? cigarettesAvoided,
    double? moneySaved,
    int? daysWithoutSmoking,
    double? healthProgress,
    String? dependencyLevel,
    List<String>? motivations,
    Map<String, dynamic>? healthMetrics,
    Map<String, dynamic>? achievements,
    List<WeeklyProgress>? weeklyData,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      cigarettesPerDay: cigarettesPerDay ?? this.cigarettesPerDay,
      packagePrice: packagePrice ?? this.packagePrice,
      cigarettesAvoided: cigarettesAvoided ?? this.cigarettesAvoided,
      moneySaved: moneySaved ?? this.moneySaved,
      daysWithoutSmoking: daysWithoutSmoking ?? this.daysWithoutSmoking,
      healthProgress: healthProgress ?? this.healthProgress,
      dependencyLevel: dependencyLevel ?? this.dependencyLevel,
      motivations: motivations ?? this.motivations,
      healthMetrics: healthMetrics ?? this.healthMetrics,
      achievements: achievements ?? this.achievements,
      weeklyData: weeklyData ?? this.weeklyData,
    );
  }

  // Calcular el porcentaje de reducción
  double get reductionPercentage {
    if (cigarettesPerDay == 0) return 0.0;
    return (cigarettesAvoided / (daysWithoutSmoking * cigarettesPerDay)) * 100;
  }

  // Obtener logros completados
  List<Achievement> getCompletedAchievements() {
    List<Achievement> completed = [];
    achievements.forEach((key, value) {
      if (value['completed'] == true) {
        completed.add(Achievement(
          id: key,
          title: value['title'] ?? '',
          description: value['description'] ?? '',
          date: value['date'] != null ? DateTime.parse(value['date']) : null,
          isCompleted: true,
        ));
      }
    });
    return completed;
  }

  // Obtener logros pendientes
  List<Achievement> getPendingAchievements() {
    List<Achievement> pending = [];
    achievements.forEach((key, value) {
      if (value['completed'] != true) {
        pending.add(Achievement(
          id: key,
          title: value['title'] ?? '',
          description: value['description'] ?? '',
          date: null,
          isCompleted: false,
          progress: value['progress'] ?? 0.0,
        ));
      }
    });
    return pending;
  }
}

// Clase para manejar el progreso semanal
class WeeklyProgress {
  final DateTime weekStart;
  final List<int> dailyCigarettes;
  final int weeklyGoal;
  final int totalSmoked;

  WeeklyProgress({
    required this.weekStart,
    required this.dailyCigarettes,
    required this.weeklyGoal,
    required this.totalSmoked,
  });

  factory WeeklyProgress.fromJson(Map<String, dynamic> json) {
    return WeeklyProgress(
      weekStart: json['weekStart'] != null 
          ? DateTime.parse(json['weekStart']) 
          : DateTime.now(),
      dailyCigarettes: List<int>.from(json['dailyCigarettes'] ?? [0, 0, 0, 0, 0, 0, 0]),
      weeklyGoal: json['weeklyGoal'] ?? 0,
      totalSmoked: json['totalSmoked'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weekStart': weekStart.toIso8601String(),
      'dailyCigarettes': dailyCigarettes,
      'weeklyGoal': weeklyGoal,
      'totalSmoked': totalSmoked,
    };
  }

  double get completionPercentage {
    if (weeklyGoal == 0) return 0.0;
    return (totalSmoked / weeklyGoal) * 100;
  }
}

// Clase para manejar los logros
class Achievement {
  final String id;
  final String title;
  final String description;
  final DateTime? date;
  final bool isCompleted;
  final double progress;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    this.date,
    required this.isCompleted,
    this.progress = 0.0,
  });
}
