class InitialTest {
  final int cigarettesPerDay;
  final bool smokesWithinMinutes;
  final bool difficultToAvoidPublicPlaces;
  final bool hatesMostToGiveUpMorningCigarette;
  final bool smokesMoreInMorning;
  final bool smokesWhenIll;
  final double packagePrice;
  final List<String> motivations;
  final int stressLevel; // 1-10
  final int anxietyLevel; // 1-10
  final Map<String, bool> healthConditions;
  
  InitialTest({
    required this.cigarettesPerDay,
    required this.smokesWithinMinutes,
    required this.difficultToAvoidPublicPlaces,
    required this.hatesMostToGiveUpMorningCigarette,
    required this.smokesMoreInMorning,
    required this.smokesWhenIll,
    required this.packagePrice,
    required this.motivations,
    required this.stressLevel,
    required this.anxietyLevel,
    required this.healthConditions,
  });
  
  // Calcula el nivel de dependencia basado en el Test de Fagerström
  String calculateDependencyLevel() {
    int score = 0;
    
    // Cigarrillos por día
    if (cigarettesPerDay <= 10) {
      score += 0;
    } else if (cigarettesPerDay <= 20) {
      score += 1;
    } else if (cigarettesPerDay <= 30) {
      score += 2;
    } else {
      score += 3;
    }
    
    // Tiempo hasta el primer cigarrillo
    if (smokesWithinMinutes) score += 1;
    
    // Dificultad para evitar lugares públicos
    if (difficultToAvoidPublicPlaces) score += 1;
    
    // Cigarrillo que más odia abandonar
    if (hatesMostToGiveUpMorningCigarette) score += 1;
    
    // Fuma más en la mañana
    if (smokesMoreInMorning) score += 1;
    
    // Fuma cuando está enfermo
    if (smokesWhenIll) score += 1;
    
    // Determinar nivel de dependencia
    if (score <= 2) {
      return 'Leve';
    } else if (score <= 5) {
      return 'Moderado';
    } else {
      return 'Severo';
    }
  }
  
  // Calcula el dinero que se gastaba mensualmente en cigarrillos
  double calculateMonthlyExpenditure() {
    // Asumiendo 20 cigarrillos por paquete
    double packsPerDay = cigarettesPerDay / 20;
    return packsPerDay * packagePrice * 30; // Gasto mensual aproximado
  }
  
  factory InitialTest.fromJson(Map<String, dynamic> json) {
    return InitialTest(
      cigarettesPerDay: json['cigarettesPerDay'] ?? 0,
      smokesWithinMinutes: json['smokesWithinMinutes'] ?? false,
      difficultToAvoidPublicPlaces: json['difficultToAvoidPublicPlaces'] ?? false,
      hatesMostToGiveUpMorningCigarette: json['hatesMostToGiveUpMorningCigarette'] ?? false,
      smokesMoreInMorning: json['smokesMoreInMorning'] ?? false,
      smokesWhenIll: json['smokesWhenIll'] ?? false,
      packagePrice: (json['packagePrice'] ?? 0.0).toDouble(),
      motivations: List<String>.from(json['motivations'] ?? []),
      stressLevel: json['stressLevel'] ?? 5,
      anxietyLevel: json['anxietyLevel'] ?? 5,
      healthConditions: Map<String, bool>.from(json['healthConditions'] ?? {}),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'cigarettesPerDay': cigarettesPerDay,
      'smokesWithinMinutes': smokesWithinMinutes,
      'difficultToAvoidPublicPlaces': difficultToAvoidPublicPlaces,
      'hatesMostToGiveUpMorningCigarette': hatesMostToGiveUpMorningCigarette,
      'smokesMoreInMorning': smokesMoreInMorning,
      'smokesWhenIll': smokesWhenIll,
      'packagePrice': packagePrice,
      'motivations': motivations,
      'stressLevel': stressLevel,
      'anxietyLevel': anxietyLevel,
      'healthConditions': healthConditions,
      'dependencyLevel': calculateDependencyLevel(),
    };
  }
}
