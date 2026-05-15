class DynamicAchievement {
  final String code;
  final String title;
  final String description;
  final String icon;
  final String color;
  final int rewardPoints;
  final double progress;
  final int progressPercentage;
  final bool unlocked;
  final String? unlockedAt;

  DynamicAchievement({
    required this.code,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.rewardPoints,
    required this.progress,
    required this.progressPercentage,
    required this.unlocked,
    this.unlockedAt,
  });

  factory DynamicAchievement.fromJson(Map<String, dynamic> json) {
    return DynamicAchievement(
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'emoji_events',
      color: json['color'] ?? '#4A90D9',
      rewardPoints: json['rewardPoints'] ?? 0,
      progress: (json['progress'] ?? 0).toDouble(),
      progressPercentage: json['progressPercentage'] ?? 0,
      unlocked: json['unlocked'] ?? false,
      unlockedAt: json['unlockedAt'],
    );
  }
}
