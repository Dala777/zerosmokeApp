class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int progressCurrent;
  final int progressTotal;
  final String category;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.isUnlocked,
    this.unlockedAt,
    required this.progressCurrent,
    required this.progressTotal,
    required this.category,
  });

  double get progressPercentage => progressTotal > 0 
      ? progressCurrent / progressTotal 
      : 0.0;

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconName: json['iconName'],
      isUnlocked: json['isUnlocked'],
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt']) 
          : null,
      progressCurrent: json['progressCurrent'],
      progressTotal: json['progressTotal'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'progressCurrent': progressCurrent,
      'progressTotal': progressTotal,
      'category': category,
    };
  }
}
