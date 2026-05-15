import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/emotional_entry.dart';
import '../models/support_contact.dart';
import '../services/api_service.dart';

class GamificationService {
  static const String baseUrl = ApiService.baseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Emotional Journal
  Future<Map<String, dynamic>> getEmotionalEntries({int limit = 50, int skip = 0}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/emotional-journal?limit=$limit&skip=$skip'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? '',
        'data': data['data'] ?? [],
        'total': data['total'] ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}', 'data': [], 'total': 0};
    }
  }

  Future<Map<String, dynamic>> getRecentEmotionalEntries({int days = 7}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/emotional-journal/recent?days=$days'),
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

  Future<Map<String, dynamic>> saveEmotionalEntry(EmotionalEntry entry) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/emotional-journal'),
        headers: headers,
        body: jsonEncode(entry.toJson()),
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 201,
        'message': data['message'] ?? '',
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Support Network
  Future<Map<String, dynamic>> getSupportContacts() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/support-network'),
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

  Future<Map<String, dynamic>> saveSupportContact(SupportContact contact) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/support-network'),
        headers: headers,
        body: jsonEncode(contact.toJson()),
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 201,
        'message': data['message'] ?? '',
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> deleteSupportContact(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/support-network/$id'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Rewards
  Future<Map<String, dynamic>> getRewards() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/rewards'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? '',
        'data': data['data'] ?? [],
        'points': data['points'] ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}', 'data': [], 'points': 0};
    }
  }

  Future<Map<String, dynamic>> unlockReward(String code) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/rewards/unlock/$code'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'message': data['message'] ?? '',
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Dynamic Achievements
  Future<Map<String, dynamic>> getDynamicAchievements() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/achievements/dynamic'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? '',
        'data': data['data'] ?? [],
        'motivationPoints': data['motivationPoints'] ?? 0,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
        'data': [],
        'motivationPoints': 0,
      };
    }
  }
}
