import 'package:flutter/material.dart';
import '../models/notification_preference.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service;

  NotificationPreference _preferences = NotificationPreference();
  List<SmartMessage> _smartMessages = [];
  bool _isLoading = false;
  String _errorMessage = '';

  NotificationProvider(this._service);

  NotificationPreference get preferences => _preferences;
  List<SmartMessage> get smartMessages => _smartMessages;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

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
}
