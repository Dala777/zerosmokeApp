class NotificationPreference {
  final bool enableDailyReminder;
  final bool enableRiskAlerts;
  final bool enableMotivation;
  final int preferredHour;
  final int quietHoursStart;
  final int quietHoursEnd;

  NotificationPreference({
    this.enableDailyReminder = true,
    this.enableRiskAlerts = true,
    this.enableMotivation = true,
    this.preferredHour = 9,
    this.quietHoursStart = 22,
    this.quietHoursEnd = 7,
  });

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    return NotificationPreference(
      enableDailyReminder: json['enableDailyReminder'] ?? true,
      enableRiskAlerts: json['enableRiskAlerts'] ?? true,
      enableMotivation: json['enableMotivation'] ?? true,
      preferredHour: json['preferredHour'] ?? 9,
      quietHoursStart: json['quietHoursStart'] ?? 22,
      quietHoursEnd: json['quietHoursEnd'] ?? 7,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enableDailyReminder': enableDailyReminder,
      'enableRiskAlerts': enableRiskAlerts,
      'enableMotivation': enableMotivation,
      'preferredHour': preferredHour,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
    };
  }

  NotificationPreference copyWith({
    bool? enableDailyReminder,
    bool? enableRiskAlerts,
    bool? enableMotivation,
    int? preferredHour,
    int? quietHoursStart,
    int? quietHoursEnd,
  }) {
    return NotificationPreference(
      enableDailyReminder: enableDailyReminder ?? this.enableDailyReminder,
      enableRiskAlerts: enableRiskAlerts ?? this.enableRiskAlerts,
      enableMotivation: enableMotivation ?? this.enableMotivation,
      preferredHour: preferredHour ?? this.preferredHour,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}

class SmartMessage {
  final String type;
  final String title;
  final String body;
  final String priority;

  SmartMessage({
    required this.type,
    required this.title,
    required this.body,
    required this.priority,
  });

  factory SmartMessage.fromJson(Map<String, dynamic> json) {
    return SmartMessage(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      priority: json['priority'] ?? 'low',
    );
  }
}
