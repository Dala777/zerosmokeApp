class EmotionalEntry {
  final String id;
  final String userId;
  final DateTime date;
  final String mood; // 'excelente', 'bueno', 'neutro', 'triste', 'ansioso'
  final int intensity; // 1-10
  final String? triggers; // Lo que causó el sentimiento
  final String? notes; // Notas adicionales
  final String? copingStrategy; // Estrategia usada

  EmotionalEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.mood,
    required this.intensity,
    this.triggers,
    this.notes,
    this.copingStrategy,
  });

  factory EmotionalEntry.fromJson(Map<String, dynamic> json) {
    return EmotionalEntry(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : DateTime.now(),
      mood: json['mood'] ?? 'neutro',
      intensity: json['intensity'] ?? 5,
      triggers: json['triggers'],
      notes: json['notes'],
      copingStrategy: json['copingStrategy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'mood': mood,
      'intensity': intensity,
      'triggers': triggers,
      'notes': notes,
      'copingStrategy': copingStrategy,
    };
  }
}
