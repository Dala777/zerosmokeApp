class CigaretteLog {
  final String id;
  final DateTime timestamp;
  final String reason;
  final String location;
  final String mood;
  final String intensity;
  final String notes;

  CigaretteLog({
    required this.id,
    required this.timestamp,
    required this.reason,
    required this.location,
    required this.mood,
    required this.intensity,
    this.notes = '',
  });

  factory CigaretteLog.fromJson(Map<String, dynamic> json) {
    return CigaretteLog(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      reason: json['reason'],
      location: json['location'],
      mood: json['mood'],
      intensity: json['intensity'],
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'reason': reason,
      'location': location,
      'mood': mood,
      'intensity': intensity,
      'notes': notes,
    };
  }

  CigaretteLog copyWith({
    String? id,
    DateTime? timestamp,
    String? reason,
    String? location,
    String? mood,
    String? intensity,
    String? notes,
  }) {
    return CigaretteLog(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      reason: reason ?? this.reason,
      location: location ?? this.location,
      mood: mood ?? this.mood,
      intensity: intensity ?? this.intensity,
      notes: notes ?? this.notes,
    );
  }
}
