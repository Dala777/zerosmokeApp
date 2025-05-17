import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String _errorMessage = '';

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String get errorMessage => _errorMessage;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await ApiService.isLoggedIn();
      
      if (isLoggedIn) {
        _user = await ApiService.getCurrentUser();
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('Error cargando usuario: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.register(name, email, password);
      
      if (response['success']) {
        if (response['data'] != null) {
          _user = User.fromJson(response['data']);
        }
      } else {
        _errorMessage = response['message'];
      }
      
      return response;
    } catch (e) {
      _errorMessage = e.toString();
      print('Error en registro: $_errorMessage');
      return {
        'success': false,
        'message': 'Error: $_errorMessage',
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.login(email, password);
      
      if (response['success']) {
        if (response['data'] != null) {
          _user = User.fromJson(response['data']);
        }
      } else {
        _errorMessage = response['message'];
      }
      
      return response;
    } catch (e) {
      _errorMessage = e.toString();
      print('Error en login: $_errorMessage');
      return {
        'success': false,
        'message': 'Error: $_errorMessage',
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.logout();
      _user = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('Error en logout: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
