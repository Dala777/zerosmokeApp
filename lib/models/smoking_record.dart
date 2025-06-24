class SmokingRecord {
  final DateTime timestamp;
  final String? emotion;
  final List<String> symptoms;
  final String? note;

  SmokingRecord({
    required this.timestamp,
    this.emotion,
    this.symptoms = const [],
    this.note,
  });

  // Agregar método toJson para serialización
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'emotion': emotion,
      'symptoms': symptoms,
      'note': note,
    };
  }

  // Agregar método fromJson para deserialización
  factory SmokingRecord.fromJson(Map<String, dynamic> json) {
    return SmokingRecord(
      timestamp: DateTime.parse(json['timestamp']),
      emotion: json['emotion'],
      symptoms: List<String>.from(json['symptoms'] ?? []),
      note: json['note'],
    );
  }
}
