import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/notification_provider.dart';
import '../models/notification_log_entry.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotificationHistory(refresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationProvider>().loadNextPage();
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'achievement': return Icons.emoji_events;
      case 'reward': return Icons.card_giftcard;
      case 'streak': return Icons.local_fire_department;
      case 'risk_alert': return Icons.warning_amber;
      case 'checkin': return Icons.fact_check;
      case 'motivation': return Icons.favorite;
      case 'smart': return Icons.notifications;
      default: return Icons.notifications_outlined;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'achievement': return AppColors.warning;
      case 'reward': return AppColors.accent;
      case 'streak': return const Color(0xFFFF6B35);
      case 'risk_alert': return AppColors.error;
      case 'checkin': return AppColors.primary;
      case 'motivation': return AppColors.success;
      case 'smart': return AppColors.secondary;
      default: return AppColors.textSecondary;
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notificaciones', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: () => provider.markAllAsRead(),
              child: const Text('Leer todas', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: provider.isLoading && provider.notificationLogs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.notificationLogs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text('Sin notificaciones', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Text('Las notificaciones aparecerán aquí', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => provider.loadNotificationHistory(refresh: true),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: provider.notificationLogs.length + (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= provider.notificationLogs.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                        );
                      }
                      final entry = provider.notificationLogs[index];
                      return _buildNotificationItem(entry, provider);
                    },
                  ),
                ),
    );
  }

  Widget _buildNotificationItem(NotificationLogEntry entry, NotificationProvider provider) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.primary,
        child: const Icon(Icons.check, color: Colors.white),
      ),
      onDismissed: (_) => provider.markAsRead(entry.id),
      child: InkWell(
        onTap: entry.isRead ? null : () => provider.markAsRead(entry.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: entry.isRead ? AppColors.cardBackground : AppColors.tertiary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(14),
            border: !entry.isRead
                ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 1)
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _typeColor(entry.type).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_typeIcon(entry.type), color: _typeColor(entry.type), size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.title,
                            style: TextStyle(
                              fontWeight: entry.isRead ? FontWeight.w500 : FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(_timeAgo(entry.sentAt), style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(entry.body, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              if (!entry.isRead)
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 6),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
