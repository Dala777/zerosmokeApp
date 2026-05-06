import 'package:intl/intl.dart';

class DailyCheckIn {
  final String id;
  final DateTime date;
  final String mood; // 'excelente', 'bueno', 'normal', 'triste', 'terrible'
  final int cravingLevel; // 0-5
  final bool smokedToday;
  final List<String> physicalSymptoms; // opcional: ['dolor_cabeza', 'ansiedad', 'insomnio', etc]
  final String? note;
  final DateTime createdAt;

  DailyCheckIn({
    required this.id,
    required this.date,
    required this.mood,
    required this.cravingLevel,
    required this.smokedToday,
    this.physicalSymptoms = const [],
    this.note,
    required this.createdAt,
  });

  // Convertir a JSON para almacenamiento
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'mood': mood,
      'cravingLevel': cravingLevel,
      'smokedToday': smokedToday,
      'physicalSymptoms': physicalSymptoms,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Crear desde JSON
  factory DailyCheckIn.fromJson(Map<String, dynamic> json) {
    return DailyCheckIn(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      mood: json['mood'] as String,
      cravingLevel: json['cravingLevel'] as int,
      smokedToday: json['smokedToday'] as bool,
      physicalSymptoms: List<String>.from(json['physicalSymptoms'] as List? ?? []),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Copiar con cambios
  DailyCheckIn copyWith({
    String? id,
    DateTime? date,
    String? mood,
    int? cravingLevel,
    bool? smokedToday,
    List<String>? physicalSymptoms,
    String? note,
    DateTime? createdAt,
  }) {
    return DailyCheckIn(
      id: id ?? this.id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      cravingLevel: cravingLevel ?? this.cravingLevel,
      smokedToday: smokedToday ?? this.smokedToday,
      physicalSymptoms: physicalSymptoms ?? this.physicalSymptoms,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Verificar si el check-in es de hoy
  bool isToday() {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  // Obtener emoji según mood
  static String getMoodEmoji(String mood) {
    switch (mood) {
      case 'excelente':
        return '😄';
      case 'bueno':
        return '😊';
      case 'normal':
        return '😐';
      case 'triste':
        return '😔';
      case 'terrible':
        return '😢';
      default:
        return '😐';
    }
  }

  // Obtener descripción según mood
  static String getMoodLabel(String mood) {
    switch (mood) {
      case 'excelente':
        return 'Excelente';
      case 'bueno':
        return 'Bueno';
      case 'normal':
        return 'Normal';
      case 'triste':
        return 'Triste';
      case 'terrible':
        return 'Terrible';
      default:
        return 'Normal';
    }
  }
}
