import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  
  NotificationProvider() {
    _loadNotifications();
  }
  
  List<NotificationModel> get notifications => [..._notifications];
  
  int get unreadCount => _notifications.where((notification) => !notification.isRead).length;
  
  void _loadNotifications() {
    // En una aplicación real, esto cargaría notificaciones desde una API o almacenamiento local
    // Por ahora, usamos datos de ejemplo
    final now = DateTime.now();
    
    _notifications = [
      NotificationModel(
        id: '1',
        title: '¡Felicidades! 24 horas sin fumar',
        body: 'Has completado tu primer día sin fumar. El monóxido de carbono ya ha sido eliminado de tu cuerpo.',
        timestamp: now.subtract(Duration(hours: 2)),
        type: 'achievement',
        isRead: false,
      ),
      NotificationModel(
        id: '2',
        title: 'Recordatorio: Registra tu progreso',
        body: 'No olvides registrar tus antojos y cigarrillos para un mejor seguimiento de tu progreso.',
        timestamp: now.subtract(Duration(hours: 8)),
        type: 'reminder',
        isRead: true,
      ),
      NotificationModel(
        id: '3',
        title: 'Consejo del día',
        body: 'Beber agua regularmente puede ayudar a reducir los antojos de nicotina y a eliminar toxinas más rápidamente.',
        timestamp: now.subtract(Duration(days: 1)),
        type: 'tip',
        isRead: true,
      ),
      NotificationModel(
        id: '4',
        title: 'Nuevo logro desbloqueado',
        body: 'Has evitado 10 cigarrillos. ¡Sigue así!',
        timestamp: now.subtract(Duration(days: 2)),
        type: 'achievement',
        isRead: true,
      ),
    ];
  }
  
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }
  
  void markAsRead(String id) {
    final index = _notifications.indexWhere((notification) => notification.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }
  
  void markAllAsRead() {
    _notifications = _notifications.map((notification) => notification.copyWith(isRead: true)).toList();
    notifyListeners();
  }
  
  void deleteNotification(String id) {
    _notifications.removeWhere((notification) => notification.id == id);
    notifyListeners();
  }
  
  void clearAllNotifications() {
    _notifications = [];
    notifyListeners();
  }
  
  void createAchievementNotification(String title, String body) {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: 'achievement',
      isRead: false,
    );
    
    addNotification(notification);
  }
  
  void createReminderNotification(String title, String body) {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: 'reminder',
      isRead: false,
    );
    
    addNotification(notification);
  }
  
  void createTipNotification(String title, String body) {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: 'tip',
      isRead: false,
    );
    
    addNotification(notification);
  }
}
