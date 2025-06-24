class Activity {
  final String id;
  final String title;
  final String description;
  final String type;
  final int durationMinutes;
  final bool isCompleted;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.durationMinutes,
    this.isCompleted = false,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
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
    };
  }

  Activity copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    int? durationMinutes,
    bool? isCompleted,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
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
    return DailyPlan(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      activities: json['activities'] != null
          ? List<Activity>.from(
              json['activities'].map((x) => Activity.fromJson(x)))
          : [],
      isCompleted: json['isCompleted'] ?? false,
      message: json['message'] ?? json['dailyMessage'] ?? '',
      dayNumber: json['dayNumber'] ?? 0,
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
