import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/smoking_record.dart';
import '../models/user_progress.dart';
import '../models/daily_plan.dart';
import '../models/daily_checkin.dart';
import '../models/initial_test.dart';
import 'api_service.dart';

class ProgressService {
  final ApiService apiService;
  static const String baseUrl = ApiService.baseUrl; // Usar la misma URL base que ApiService

  ProgressService(this.apiService);

  // Método para obtener headers con token de autenticación
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Guardar test inicial
  Future<Map<String, dynamic>> saveInitialTest(InitialTest test) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/progress/initial-test'),
        headers: headers,
        body: jsonEncode(test.toJson()),
      );

      final responseData = jsonDecode(response.body);

      return {
        'success': response.statusCode == 201,
        'message': responseData['message'] ?? 'Unknown error',
        'data': responseData['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Obtener progreso del usuario
  Future<Map<String, dynamic>> getUserProgress() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/progress/user-progress'),
        headers: headers,
      );

      final responseData = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ?? 'Unknown error',
        'data': responseData['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Obtener progreso semanal
  Future<Map<String, dynamic>> getWeeklyProgress() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/progress/weekly-progress'),
        headers: headers,
      );

      final responseData = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ?? 'Unknown error',
        'data': responseData['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Obtener logros
  Future<Map<String, dynamic>> getAchievements() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/progress/achievements'),
        headers: headers,
      );

      final responseData = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ?? 'Unknown error',
        'data': responseData['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getTodayDailyCheckIn() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/progress/daily-checkin/today'),
        headers: headers,
      );

      final responseData = jsonDecode(response.body);
      print('[daily-checkin/today] status=${response.statusCode} body=${response.body}');

      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ?? 'Unknown error',
        'hasCheckin': responseData['hasCheckin'] == true || responseData['checkin'] != null || responseData['data'] != null,
        'checkin': responseData['checkin'] ?? responseData['data'],
        'data': responseData['checkin'] ?? responseData['data'],
        'dateKey': responseData['dateKey'],
        'timezoneOffsetMinutes': responseData['timezoneOffsetMinutes'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> saveDailyCheckIn(DailyCheckIn checkIn) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/progress/daily-checkin'),
        headers: headers,
        body: jsonEncode(checkIn.toJson()),
      );

      final responseData = jsonDecode(response.body);
      print('[daily-checkin/save] status=${response.statusCode} body=${response.body}');

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'message': responseData['message'] ?? 'Unknown error',
        'hasCheckin': responseData['hasCheckin'] == true,
        'checkin': responseData['checkin'],
        'data': responseData['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Actualizar progreso del usuario
  Future<Map<String, dynamic>> updateUserProgress(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/progress/user-progress'),
        headers: headers,
        body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ?? 'Unknown error',
        'data': responseData['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Guardar registro de cigarrillo
  Future<Map<String, dynamic>> saveSmokingRecord(SmokingRecord recordData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/progress/smoking-record'),
        headers: headers,
        body: jsonEncode({
          'timestamp': recordData.timestamp.toIso8601String(),
          'emotion': recordData.emotion,
          'symptoms': recordData.symptoms,
          'note': recordData.note,
        }),
      );

      final responseData = jsonDecode(response.body);

      return {
        'success': response.statusCode == 201,
        'message': responseData['message'] ?? 'Unknown error',
        'data': responseData['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Obtener plan diario
  Future<Map<String, dynamic>> getDailyPlan({DateTime? date}) async {
    try {
      final headers = await _getHeaders();
      String url = '$baseUrl/progress/daily-plan';
      
      if (date != null) {
        url += '?date=${date.toIso8601String()}';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      final responseData = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ?? 'Unknown error',
        'data': responseData['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Obtener riesgo del día
  Future<Map<String, dynamic>> getTodayRisk() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/risk/today'),
        headers: headers,
      );
      final responseData = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ?? '',
        'data': responseData['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'data': null,
      };
    }
  }

  // Completar actividad
  Future<Map<String, dynamic>> completeActivity(String planId, String activityId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/progress/daily-plan/$planId/activity/$activityId/complete'),
        headers: headers,
      );

      final responseData = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ?? 'Unknown error',
        'data': responseData['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}
