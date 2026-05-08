import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String type;
  final bool isRead;
  final String? actionRoute;
  final Map<String, dynamic>? actionParams;
  final String? imageUrl;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.actionRoute,
    this.actionParams,
    this.imageUrl,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
      isRead: json['isRead'] ?? false,
      actionRoute: json['actionRoute'],
      actionParams: json['actionParams'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'isRead': isRead,
      'actionRoute': actionRoute,
      'actionParams': actionParams,
      'imageUrl': imageUrl,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    String? type,
    bool? isRead,
    String? actionRoute,
    Map<String, dynamic>? actionParams,
    String? imageUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute ?? this.actionRoute,
      actionParams: actionParams ?? this.actionParams,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  IconData get typeIcon {
    switch (type) {
      case 'achievement':
        return Icons.emoji_events;
      case 'reminder':
        return Icons.alarm;
      case 'milestone':
        return Icons.flag;
      case 'tip':
        return Icons.lightbulb;
      case 'motivation':
        return Icons.favorite;
      case 'system':
        return Icons.notifications;
      default:
        return Icons.notifications;
    }
  }

  Color get typeColor {
    switch (type) {
      case 'achievement':
        return Colors.amber;
      case 'reminder':
        return Colors.blue;
      case 'milestone':
        return Colors.green;
      case 'tip':
        return Colors.purple;
      case 'motivation':
        return Colors.red;
      case 'system':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
