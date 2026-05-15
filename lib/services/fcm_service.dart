import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmService {
  FirebaseMessaging? _messaging;
  bool _initialized = false;
  bool _firebaseAvailable = false;

  bool get isFirebaseAvailable => _firebaseAvailable;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await Firebase.initializeApp();
      _firebaseAvailable = true;
      _messaging = FirebaseMessaging.instance;
      print('[fcm] Firebase initialized successfully');
    } catch (e) {
      print('[fcm] Firebase not available (not configured): $e');
      _firebaseAvailable = false;
      return;
    }

    await _requestPermissions();
    await _setupTokenRefresh();
    _setupForegroundHandler();
    _setupBackgroundHandler();
  }

  Future<void> _requestPermissions() async {
    try {
      if (_messaging == null) return;
      final settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      print('[fcm] Permission granted: ${settings.authorizationStatus}');
    } catch (e) {
      if (kIsWeb) {
        print('[fcm] Web notification permission handled separately');
      } else {
        print('[fcm] Permission request error: $e');
      }
    }
  }

  Future<String?> getFcmToken() async {
    if (_messaging == null) return null;
    try {
      final token = await _messaging!.getToken();
      if (token != null) {
        print('[fcm] Token obtained: ${token.length > 20 ? "${token.substring(0, 20)}..." : token}');
      }
      return token;
    } catch (e) {
      print('[fcm] Token retrieval error: $e');
      return null;
    }
  }

  Future<void> deleteFcmToken() async {
    if (_messaging == null) return;
    try {
      await _messaging!.deleteToken();
      print('[fcm] Token deleted');
    } catch (e) {
      print('[fcm] Token deletion error: $e');
    }
  }

  Future<void> _setupTokenRefresh() async {
    if (_messaging == null) return;
    try {
      _messaging!.onTokenRefresh.listen((newToken) {
        print('[fcm] Token refreshed: ${newToken.length > 20 ? "${newToken.substring(0, 20)}..." : newToken}');
      });
      print('[fcm] Token refresh listener active');
    } catch (e) {
      print('[fcm] Token refresh setup error: $e');
    }
  }

  void _setupForegroundHandler() {
    if (_messaging == null) return;
    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        if (notification != null) {
          print('[fcm] Foreground push received: "${notification.title}"');
        } else {
          print('[fcm] Foreground data message received');
        }
      });
      print('[fcm] Foreground handler active');
    } catch (e) {
      print('[fcm] Foreground handler error: $e');
    }
  }

  void _setupBackgroundHandler() {
    try {
      FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
      print('[fcm] Background handler registered');
    } catch (e) {
      print('[fcm] Background handler may not be supported on this platform: $e');
    }
  }

  String get platform {
    if (kIsWeb) return 'web';
    try {
      return 'android';
    } catch (_) {
      return 'android';
    }
  }
}

@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {
  final notification = message.notification;
  if (notification != null) {
    print('[fcm] Background push: "${notification.title}"');
  } else {
    print('[fcm] Background data message');
  }
}
