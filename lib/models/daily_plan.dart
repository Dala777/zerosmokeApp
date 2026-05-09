class Activity {
  final String id;
  final String title;
  final String description;
  final String type; // 'exercise', 'reflection', 'breathing', etc.
  final int durationMinutes;
  final bool isCompleted;
  final String? justification;
  final Map<String, dynamic>? secondaryActivity;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.durationMinutes,
    this.isCompleted = false,
    this.justification,
    this.secondaryActivity,
  });

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      durationMinutes: _toInt(json['durationMinutes']),
      isCompleted: json['isCompleted'] ?? false,
      justification: json['justification'],
      secondaryActivity: json['secondaryActivity'] is Map
          ? Map<String, dynamic>.from(json['secondaryActivity'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'durationMinutes': durationMinutes,
      'isCompleted': isCompleted,
      'justification': justification,
      'secondaryActivity': secondaryActivity,
    };
  }

  Activity copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    int? durationMinutes,
    bool? isCompleted,
    String? justification,
    Map<String, dynamic>? secondaryActivity,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      justification: justification ?? this.justification,
      secondaryActivity: secondaryActivity ?? this.secondaryActivity,
    );
  }
}

class DailyPlan {
  final String id;
  final String userId;
  final DateTime date;
  final List<Activity> activities;
  final bool isCompleted;
  final String message;
  final int dayNumber;

  DailyPlan({
    required this.id,
    required this.userId,
    required this.date,
    required this.activities,
    this.isCompleted = false,
    this.message = '',
    required this.dayNumber,
  });

  factory DailyPlan.fromJson(Map<String, dynamic> json) {
    final rawActivities = json['activities'];

    return DailyPlan(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      activities: rawActivities is List
          ? rawActivities
              .map<Activity>((x) => Activity.fromJson(Map<String, dynamic>.from(x)))
              .toList()
          : [],
      isCompleted: json['isCompleted'] ?? false,
      message: json['message'] ?? '',
      dayNumber: Activity._toInt(json['dayNumber']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'activities': activities.map((x) => x.toJson()).toList(),
      'isCompleted': isCompleted,
      'message': message,
      'dayNumber': dayNumber,
    };
  }

  DailyPlan copyWith({
    String? id,
    String? userId,
    DateTime? date,
    List<Activity>? activities,
    bool? isCompleted,
    String? message,
    int? dayNumber,
  }) {
    return DailyPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      activities: activities ?? this.activities,
      isCompleted: isCompleted ?? this.isCompleted,
      message: message ?? this.message,
      dayNumber: dayNumber ?? this.dayNumber,
    );
  }

  double get completionPercentage {
    if (activities.isEmpty) return 0.0;
    int completed = activities.where((activity) => activity.isCompleted).length;
    return completed / activities.length;
  }
}
