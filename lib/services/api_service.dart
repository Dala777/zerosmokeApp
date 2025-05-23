import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class ApiService {
  // Cambia esta URL según dónde esté ejecutándose tu servidor
  // Para emulador Android: 10.0.2.2 (apunta a localhost de tu máquina)
  // Para dispositivo físico: usa la IP de tu máquina en la red local
  // Para producción: usa tu dominio real
  
  // Prueba con estas opciones:
  //static const String baseUrl = 'http://10.0.2.2:5000/api'; // Emulador Android -> PC localhost
  // static const String baseUrl = 'http://localhost:5000/api'; // iOS Simulator -> Mac localhost
  //static const String baseUrl = 'http://192.168.1.85:5000/api'; // Reemplaza X con tu IP local
  static const String baseUrl = 'http://10.7.2.6:5000/api';
  //static const String baseUrl = 'http://192.168.43.102:5000/api';


  // Headers para las peticiones API
  static Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (requiresAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Login de usuario
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Intentando login en: $baseUrl/auth/login');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _getHeaders(requiresAuth: false),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10)); // Añadir timeout para evitar esperas largas

      print('Respuesta del servidor: ${response.statusCode}');
      print('Cuerpo de respuesta: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Guardar token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseData['token']);
        
        // Guardar datos del usuario si están disponibles
        if (responseData['user'] != null) {
          await prefs.setString('user', jsonEncode(responseData['user']));
        }
        
        return {
          'success': true,
          'message': 'Login exitoso',
          'data': responseData['user'],
        };
      } else {
        final responseData = response.body.isNotEmpty 
            ? jsonDecode(response.body) 
            : {'message': 'Error desconocido'};
            
        return {
          'success': false,
          'message': responseData['message'] ?? 'Error desconocido',
        };
      }
    } catch (e) {
      print('Error en login: $e');
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  // Registro de usuario
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      print('Intentando registro en: $baseUrl/auth/register');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: await _getHeaders(requiresAuth: false),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('Respuesta del servidor: ${response.statusCode}');
      print('Cuerpo de respuesta: ${response.body}');
      
      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        // Guardar token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseData['token']);
        
        // Guardar datos del usuario si están disponibles
        if (responseData['user'] != null) {
          await prefs.setString('user', jsonEncode(responseData['user']));
        }
        
        return {
          'success': true,
          'message': 'Registro exitoso',
          'data': responseData['user'],
        };
      } else {
        final responseData = response.body.isNotEmpty 
            ? jsonDecode(response.body) 
            : {'message': 'Error desconocido'};
            
        return {
          'success': false,
          'message': responseData['message'] ?? 'Error desconocido',
        };
      }
    } catch (e) {
      print('Error en registro: $e');
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  // Obtener perfil del usuario actual
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Actualizar datos del usuario en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(responseData));
        
        return {
          'success': true,
          'message': 'Perfil obtenido con éxito',
          'data': responseData,
        };
      } else {
        final responseData = response.body.isNotEmpty 
            ? jsonDecode(response.body) 
            : {'message': 'Error desconocido'};
            
        return {
          'success': false,
          'message': responseData['message'] ?? 'Error desconocido',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  // Cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  // Verificar si el usuario está logueado
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null;
  }

  // Obtener usuario actual desde almacenamiento local
  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    
    return null;
  }
}
