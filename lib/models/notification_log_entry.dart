class NotificationLogEntry {
  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime sentAt;
  final DateTime? readAt;
  final Map<String, dynamic>? metadata;

  NotificationLogEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.sentAt,
    this.readAt,
    this.metadata,
  });

  factory NotificationLogEntry.fromJson(Map<String, dynamic> json) {
    return NotificationLogEntry(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'smart',
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : DateTime.now(),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }

  bool get isRead => readAt != null;
}
