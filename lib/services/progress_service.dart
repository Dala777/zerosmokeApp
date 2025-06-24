import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/smoking_record.dart';
import '../models/user_progress.dart';
import '../models/daily_plan.dart';
import '../models/initial_test.dart';
import 'api_service.dart';

class ProgressService {
  final ApiService apiService;
  static const String baseUrl = ApiService.baseUrl;

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

  // Asignar plan basado en el puntaje de Fagerström
  Future<Map<String, dynamic>> assignPlan(int fagerstromScore) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/progress/assign-plan'),
        headers: headers,
        body: jsonEncode({
          'fagerstromScore': fagerstromScore,
        }),
      );

      final responseData = jsonDecode(response.body);

      return {
        'success': response.statusCode == 201 || response.statusCode == 200,
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
        final dateStr = date.toIso8601String().split('T')[0];
        url += '?date=$dateStr';
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

  // Completar actividad
  Future<Map<String, dynamic>> completeActivity(String planId, String activityId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/progress/daily-plan/$planId/activity/$activityId/complete'),
        headers: headers,
        body: jsonEncode({}),
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
