import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_preference.dart';
import '../models/notification_log_entry.dart';
import '../services/notification_service.dart';
import '../services/fcm_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service;
  final FcmService _fcmService = FcmService();

  NotificationPreference _preferences = NotificationPreference();
  List<SmartMessage> _smartMessages = [];
  List<NotificationLogEntry> _notificationLogs = [];
  bool _isLoading = false;
  String _errorMessage = '';
  int _unreadCount = 0;
  bool _fcmReady = false;
  String? _fcmToken;
  int _currentPage = 1;
  bool _hasMore = true;

  NotificationProvider(this._service);

  NotificationPreference get preferences => _preferences;
  List<SmartMessage> get smartMessages => _smartMessages;
  List<NotificationLogEntry> get notificationLogs => _notificationLogs;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;
  bool get fcmReady => _fcmReady;
  String? get fcmToken => _fcmToken;
  bool get hasMore => _hasMore;

  Future<void> initializeFcm() async {
    await _fcmService.initialize();
    _fcmReady = _fcmService.isFirebaseAvailable;
    if (_fcmReady) {
      _fcmToken = await _fcmService.getFcmToken();
      if (_fcmToken != null) {
        await _registerCurrentDevice();
        _setupForegroundListener();
        _setupTokenRefreshListener();
      }
    }
    notifyListeners();
  }

  Future<void> _registerCurrentDevice() async {
    if (_fcmToken == null) return;
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('token');
    if (authToken == null) {
      print('[fcm] Skipping register: no auth token found');
      return;
    }
    final res = await _service.registerDevice(_fcmToken!, _fcmService.platform);
    if (res['success']) {
      print('[fcm] Token registered to backend');
    } else {
      print('[fcm] Register device failed: ${res['message']}');
    }
  }

  Future<void> retryRegisterDevice() async {
    if (_fcmToken == null) {
      print('[fcm] retryRegisterDevice: no FCM token yet');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('token');
    if (authToken == null) {
      print('[fcm] retryRegisterDevice: no auth token yet');
      return;
    }
    if (_fcmReady) {
      print('[fcm] retryRegisterDevice: attempting registration');
      await _registerCurrentDevice();
    } else {
      print('[fcm] retryRegisterDevice: FCM not ready, reinitializing');
      await initializeFcm();
    }
  }

  void _setupForegroundListener() {
    try {
      FirebaseMessaging.onMessage.listen((message) {
        final notification = message.notification;
        if (notification != null) {
          print('[fcm] Foreground notification: ${notification.title}');
        }
        _refreshHistory();
      });
    } catch (_) {}
  }

  void _setupTokenRefreshListener() {
    try {
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        print('[fcm] Token refresh detected in provider');
        onFcmTokenRefresh(newToken);
      });
    } catch (_) {}
  }

  Future<void> onFcmTokenRefresh(String newToken) async {
    _fcmToken = newToken;
    await _registerCurrentDevice();
    notifyListeners();
  }

  Future<void> loadPreferences() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _service.getPreferences();
      if (res['success'] && res['data'] != null) {
        _preferences = NotificationPreference.fromJson(Map<String, dynamic>.from(res['data']));
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePreferences(NotificationPreference prefs) async {
    try {
      final res = await _service.updatePreferences(prefs);
      if (res['success'] && res['data'] != null) {
        _preferences = NotificationPreference.fromJson(Map<String, dynamic>.from(res['data']));
        notifyListeners();
        return true;
      }
      _errorMessage = res['message'] ?? '';
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<void> loadSmartMessages() async {
    try {
      final res = await _service.getSmartMessages();
      if (res['success']) {
        _smartMessages = (res['data'] as List)
            .map((m) => SmartMessage.fromJson(Map<String, dynamic>.from(m)))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> loadNotificationHistory({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _notificationLogs = [];
    }
    if (!_hasMore && !refresh) return;

    _isLoading = true;
    notifyListeners();

    try {
      final res = await _service.getNotificationHistory(page: _currentPage);
      if (res['success']) {
        final items = (res['data'] as List)
            .map((n) => NotificationLogEntry.fromJson(Map<String, dynamic>.from(n)))
            .toList();
        if (refresh) {
          _notificationLogs = items;
        } else {
          _notificationLogs.addAll(items);
        }
        _unreadCount = res['unread'] ?? 0;
        final pagination = res['pagination'];
        if (pagination != null) {
          _hasMore = _currentPage < (pagination['totalPages'] ?? 1);
        } else {
          _hasMore = false;
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNextPage() async {
    if (!_hasMore || _isLoading) return;
    _currentPage++;
    await loadNotificationHistory();
  }

  Future<void> _refreshHistory() async {
    await loadNotificationHistory(refresh: true);
  }

  Future<void> markAsRead(String id) async {
    await _service.markNotificationRead(id);
    final idx = _notificationLogs.indexWhere((n) => n.id == id);
    if (idx != -1) {
      final old = _notificationLogs[idx];
      _notificationLogs[idx] = NotificationLogEntry(
        id: old.id,
        title: old.title,
        body: old.body,
        type: old.type,
        sentAt: old.sentAt,
        readAt: DateTime.now(),
        metadata: old.metadata,
      );
      if (_unreadCount > 0) _unreadCount--;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    await _service.markAllNotificationsRead();
    _notificationLogs = _notificationLogs.map((n) {
      if (!n.isRead) {
        return NotificationLogEntry(
          id: n.id,
          title: n.title,
          body: n.body,
          type: n.type,
          sentAt: n.sentAt,
          readAt: DateTime.now(),
          metadata: n.metadata,
        );
      }
      return n;
    }).toList();
    _unreadCount = 0;
    notifyListeners();
  }
}
