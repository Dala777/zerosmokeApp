import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_preference.dart';
import 'api_service.dart';

class NotificationService {
  static const String baseUrl = ApiService.baseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getPreferences() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/preferences'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? '',
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> updatePreferences(NotificationPreference prefs) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/preferences'),
        headers: headers,
        body: jsonEncode(prefs.toJson()),
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? '',
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getSmartMessages() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/smart-messages'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? '',
        'data': data['data'] ?? [],
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}', 'data': []};
    }
  }

  // --- FCM Device Registration ---

  Future<Map<String, dynamic>> registerDevice(String fcmToken, String platform, {String? deviceName}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/register-device'),
        headers: headers,
        body: jsonEncode({
          'fcmToken': fcmToken,
          'platform': platform,
          'deviceName': deviceName ?? '',
        }),
      );
      final data = jsonDecode(response.body);
      final success = response.statusCode == 200 || response.statusCode == 201;
      if (success) {
        print('[notif] Device registered: ${fcmToken.length > 20 ? "${fcmToken.substring(0, 20)}..." : fcmToken}');
      }
      return {'success': success, 'message': data['message'] ?? ''};
    } catch (e) {
      print('[notif] Register device error: $e');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> unregisterDevice(String fcmToken) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/notifications/unregister-device?fcmToken=$fcmToken'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      return {'success': response.statusCode == 200, 'message': data['message'] ?? ''};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // --- Notification History ---

  Future<Map<String, dynamic>> getNotificationHistory({int page = 1, int limit = 20}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/history?page=$page&limit=$limit'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'data': data['data'] ?? [],
        'unread': data['unread'] ?? 0,
        'pagination': data['pagination'],
      };
    } catch (e) {
      return {'success': false, 'data': [], 'unread': 0, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> markNotificationRead(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/history/$id/read'),
        headers: headers,
      );
      return {'success': response.statusCode == 200};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> markAllNotificationsRead() async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/history/read-all'),
        headers: headers,
      );
      return {'success': response.statusCode == 200};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}
