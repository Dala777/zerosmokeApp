class RewardItem {
  final String code;
  final String title;
  final String description;
  final int cost;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  RewardItem({
    required this.code,
    required this.title,
    required this.description,
    required this.cost,
    required this.isUnlocked,
    this.unlockedAt,
  });

  factory RewardItem.fromJson(Map<String, dynamic> json) {
    return RewardItem(
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      cost: json['cost'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.tryParse(json['unlockedAt'])
          : null,
    );
  }
}
