class UserProgress {
  final String userId;
  final DateTime startDate;
  final int cigarettesPerDay;
  final double packagePrice;
  final int cigarettesAvoided;
  final double moneySaved;
  final int daysWithoutSmoking;
  final double healthProgress;
  final int cigarettesSmokedToday;
  final int bestStreak;
  final int planCurrentDay;
  final int planTotalDays;
  final double planProgress;
  final DateTime? planStartDate;
  final int motivationPoints;
  final List<Map<String, dynamic>> emotionStats;
  final List<Map<String, dynamic>> symptomStats;
  final String dependencyLevel;
  final List<String> motivations;
  final Map<String, dynamic> healthMetrics;
  final Map<String, dynamic> achievements;
  final List<WeeklyProgress> weeklyData;
  final Map<String, dynamic>? assignedPlan; // información básica del plan seleccionada

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is! List) return [];
    return value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  UserProgress({
    required this.userId,
    required this.startDate,
    required this.cigarettesPerDay,
    required this.packagePrice,
    this.cigarettesAvoided = 0,
    this.moneySaved = 0.0,
    this.daysWithoutSmoking = 0,
    this.healthProgress = 0.0,
    this.cigarettesSmokedToday = 0,
    this.bestStreak = 0,
    this.planCurrentDay = 0,
    this.planTotalDays = 0,
    this.planProgress = 0.0,
    this.planStartDate,
    this.motivationPoints = 0,
    this.emotionStats = const [],
    this.symptomStats = const [],
    this.dependencyLevel = 'Moderado',
    this.motivations = const [],
    this.healthMetrics = const {},
    this.achievements = const {},
    this.weeklyData = const [],
    this.assignedPlan,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    final rawWeeklyData = json['weeklyData'];

    return UserProgress(
      userId: json['userId'] ?? '',
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate']) 
          : DateTime.now(),
      cigarettesPerDay: _toInt(json['cigarettesPerDay']),
      packagePrice: _toDouble(json['packagePrice']),
      cigarettesAvoided: _toInt(json['cigarettesAvoided']),
      moneySaved: _toDouble(json['moneySaved']),
      daysWithoutSmoking: _toInt(json['daysWithoutSmoking']),
      healthProgress: _toDouble(json['healthProgress']),
      cigarettesSmokedToday: _toInt(json['cigarettesSmokedToday']),
      bestStreak: _toInt(json['bestStreak']),
      planCurrentDay: _toInt(json['planCurrentDay']),
      planTotalDays: _toInt(json['planTotalDays']),
      planProgress: _toDouble(json['planProgress']),
      planStartDate: json['planStartDate'] != null
          ? DateTime.tryParse(json['planStartDate'].toString())
          : null,
      motivationPoints: _toInt(json['motivationPoints']),
      emotionStats: _mapList(json['emotionStats']),
      symptomStats: _mapList(json['symptomStats']),
      dependencyLevel: json['dependencyLevel'] ?? 'Moderado',
      motivations: List<String>.from(json['motivations'] ?? []),
      healthMetrics: json['healthMetrics'] ?? {},
      achievements: json['achievements'] ?? {},
      weeklyData: rawWeeklyData is List
          ? rawWeeklyData.map<WeeklyProgress>(
              (x) => WeeklyProgress.fromJson(Map<String, dynamic>.from(x)),
            ).toList()
          : [],
      assignedPlan: json['assignedPlan'] != null
          ? Map<String, dynamic>.from(json['assignedPlan'])
          : null,
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
      'cigarettesSmokedToday': cigarettesSmokedToday,
      'bestStreak': bestStreak,
      'planCurrentDay': planCurrentDay,
      'planTotalDays': planTotalDays,
      'planProgress': planProgress,
      'planStartDate': planStartDate?.toIso8601String(),
      'motivationPoints': motivationPoints,
      'emotionStats': emotionStats,
      'symptomStats': symptomStats,
      'dependencyLevel': dependencyLevel,
      'motivations': motivations,
      'healthMetrics': healthMetrics,
      'achievements': achievements,
      'weeklyData': weeklyData.map((x) => x.toJson()).toList(),
      'assignedPlan': assignedPlan,
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
    int? cigarettesSmokedToday,
    int? bestStreak,
    int? planCurrentDay,
    int? planTotalDays,
    double? planProgress,
    DateTime? planStartDate,
    int? motivationPoints,
    List<Map<String, dynamic>>? emotionStats,
    List<Map<String, dynamic>>? symptomStats,
    String? dependencyLevel,
    List<String>? motivations,
    Map<String, dynamic>? healthMetrics,
    Map<String, dynamic>? achievements,
    List<WeeklyProgress>? weeklyData,
    Map<String, dynamic>? assignedPlan,
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
      cigarettesSmokedToday: cigarettesSmokedToday ?? this.cigarettesSmokedToday,
      bestStreak: bestStreak ?? this.bestStreak,
      planCurrentDay: planCurrentDay ?? this.planCurrentDay,
      planTotalDays: planTotalDays ?? this.planTotalDays,
      planProgress: planProgress ?? this.planProgress,
      planStartDate: planStartDate ?? this.planStartDate,
      motivationPoints: motivationPoints ?? this.motivationPoints,
      emotionStats: emotionStats ?? this.emotionStats,
      symptomStats: symptomStats ?? this.symptomStats,
      dependencyLevel: dependencyLevel ?? this.dependencyLevel,
      motivations: motivations ?? this.motivations,
      healthMetrics: healthMetrics ?? this.healthMetrics,
      achievements: achievements ?? this.achievements,
      weeklyData: weeklyData ?? this.weeklyData,
      assignedPlan: assignedPlan ?? this.assignedPlan,
    );
  }

  // Calcular el porcentaje de reducción
  double get reductionPercentage {
    final baseline = daysWithoutSmoking * cigarettesPerDay;
    if (cigarettesPerDay <= 0 || daysWithoutSmoking <= 0 || baseline <= 0) return 0.0;
    return (cigarettesAvoided / baseline) * 100;
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
          progress: _toDouble(value['progress']),
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
  final int baselineExpected;
  final int cigarettesAvoided;
  final int reductionPercentage;
  final String label;

  WeeklyProgress({
    required this.weekStart,
    required this.dailyCigarettes,
    required this.weeklyGoal,
    required this.totalSmoked,
    this.baselineExpected = 0,
    this.cigarettesAvoided = 0,
    this.reductionPercentage = 0,
    this.label = '',
  });

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  factory WeeklyProgress.fromJson(Map<String, dynamic> json) {
    final rawDaily =
        json['dailyCigarettes'] is List ? json['dailyCigarettes'] as List : const [];
    return WeeklyProgress(
      weekStart: json['weekStart'] != null 
          ? DateTime.parse(json['weekStart']) 
          : DateTime.now(),
      dailyCigarettes: rawDaily.map<int>(_toInt).toList(),
      weeklyGoal: _toInt(json['weeklyGoal']),
      totalSmoked: _toInt(json['totalSmoked']),
      baselineExpected: _toInt(json['baselineExpected'] ?? json['weeklyGoal']),
      cigarettesAvoided: _toInt(json['cigarettesAvoided']),
      reductionPercentage: _toInt(json['reductionPercentage']),
      label: (json['label'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weekStart': weekStart.toIso8601String(),
      'dailyCigarettes': dailyCigarettes,
      'weeklyGoal': weeklyGoal,
      'totalSmoked': totalSmoked,
      'baselineExpected': baselineExpected,
      'cigarettesAvoided': cigarettesAvoided,
      'reductionPercentage': reductionPercentage,
      'label': label,
    };
  }

  double get completionPercentage {
    if (reductionPercentage > 0) return reductionPercentage.toDouble();
    if (weeklyGoal <= 0) return 0.0;
    final reduction = ((weeklyGoal - totalSmoked) / weeklyGoal) * 100;
    return reduction.clamp(0.0, 100.0).toDouble();
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
