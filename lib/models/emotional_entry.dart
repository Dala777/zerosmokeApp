class EmotionalEntry {
  final String id;
  final String userId;
  final DateTime date;
  final String mood;
  final int intensity;
  final String? triggers;
  final String? notes;
  final List<String> tags;
  final DateTime? createdAt;

  EmotionalEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.mood,
    this.intensity = 5,
    this.triggers,
    this.notes,
    this.tags = const [],
    this.createdAt,
  });

  factory EmotionalEntry.fromJson(Map<String, dynamic> json) {
    return EmotionalEntry(
      id: json['_id'] ?? '',
      userId: json['userId'] is Map
          ? (json['userId'] as Map)['_id']?.toString() ?? ''
          : json['userId']?.toString() ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      mood: json['mood'] ?? 'neutro',
      intensity: json['intensity'] ?? 5,
      triggers: json['triggers'],
      notes: json['notes'] ?? json['note'],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'mood': mood,
      'intensity': intensity,
      'triggers': triggers,
      'notes': notes,
      'tags': tags,
    };
  }
}
