import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  String? _accessToken;
  String? _refreshToken;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  String? get token => _accessToken;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _accessToken != null && _currentUser != null;

  final ApiService _apiService = ApiService();

  AuthService() {
    _loadUserData();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString(Constants.tokenKey);
      _refreshToken = prefs.getString(Constants.refreshTokenKey);
      
      final userJson = prefs.getString(Constants.userKey);
      if (userJson != null) {
        _currentUser = User.fromJson(json.decode(userJson));
      }
      
      // Si tenemos token, configurarlo en ApiService
      if (_accessToken != null) {
        _apiService.setAuthToken(_accessToken);
        debugPrint('🔑 Token cargado desde SharedPreferences');
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading user data: $e');
    }
  }

  Future<void> _saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_accessToken != null) {
        await prefs.setString(Constants.tokenKey, _accessToken!);
      }
      
      if (_refreshToken != null) {
        await prefs.setString(Constants.refreshTokenKey, _refreshToken!);
      }
      
      if (_currentUser != null) {
        await prefs.setString(Constants.userKey, json.encode(_currentUser!.toJson()));
      }
      
      debugPrint('✅ User data guardado en SharedPreferences');
    } catch (e) {
      debugPrint('❌ Error saving user data: $e');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _setLoading(true);
    
    try {
      debugPrint('🔐 Intentando login con: $email');
      
      final response = await _apiService.postFormData(
        Constants.loginEndpoint,
        {
          'username': email,
          'password': password,
        },
      );

      debugPrint('✅ Login exitoso');
      _accessToken = response['access_token'];
      _refreshToken = response['refresh_token'];
      
      // ✅ Setear token en ApiService
      _apiService.setAuthToken(_accessToken);
      
      // Cargar datos del usuario
      await loadCurrentUser();
      
      await _saveUserData();
      
      _setLoading(false);
      return {'success': true, 'message': 'Login exitoso'};
      
    } on ApiException catch (e) {
      _setLoading(false);
      return {'success': false, 'message': e.message};
      
    } catch (e) {
      _setLoading(false);
      return {'success': false, 'message': 'Error inesperado: $e'};
    }
  }

  Future<Map<String, dynamic>> register(User user, String password) async {
    _setLoading(true);

    try {
      final response = await _apiService.post(
        Constants.registerEndpoint,
        {
          'email': user.email,
          'first_name': user.nombre,
          'last_name': user.apellidos,
          'password': password,
          'gender': user.sexo,
          'birth_date': user.fechaNacimiento.toIso8601String().split('T')[0],
        },
      );

      // Procesar respuesta exitosa
      _accessToken = response['access_token'];
      _refreshToken = response['refresh_token'];
      
      _apiService.setAuthToken(_accessToken);
      _currentUser = user;
      
      await _saveUserData();
      notifyListeners();
      
      _setLoading(false);
      return {'success': true, 'message': 'Usuario registrado exitosamente'};
      
    } on ApiException catch (e) {
      _setLoading(false);
      return {'success': false, 'message': e.message};
    } catch (e) {
      _setLoading(false);
      return {'success': false, 'message': 'Error inesperado: $e'};
    }
  }

  Future<void> resetPassword(String email) async {
    _setLoading(true);
    
    try {
      await _apiService.post(
        Constants.resetPasswordEndpoint,
        {'email': email},
      );
    } catch (e) {
      debugPrint('Reset password error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Limpiar SharedPreferences
      await prefs.remove(Constants.tokenKey);
      await prefs.remove(Constants.refreshTokenKey);
      await prefs.remove(Constants.userKey);
      
      // Limpiar variables locales
      _currentUser = null;
      _accessToken = null;
      _refreshToken = null;
      
      // ✅ Limpiar token en ApiService
      _apiService.setAuthToken(null);
      
      notifyListeners();
      debugPrint('👋 Usuario cerró sesión');
    } catch (e) {
      debugPrint('❌ Error en logout: $e');
    }
  }

  Future<void> updateUser(User updatedUser) async {
    _currentUser = updatedUser;
    await _saveUserData();
    notifyListeners();
  }

  Future<void> loadCurrentUser() async {
    if (_accessToken == null) {
      debugPrint('⚠️ No hay token, no se puede cargar usuario');
      return;
    }
    
    try {
      debugPrint('🔑 Token presente, cargando usuario actual...');
      
      // ✅ Setear token en ApiService
      _apiService.setAuthToken(_accessToken);
      
      final response = await _apiService.get(Constants.userMeEndpoint);
      _currentUser = User.fromJson(response);
      
      debugPrint('✅ Usuario cargado: ${_currentUser!.email}');
      await _saveUserData();
      notifyListeners();
      
    } catch (e) {
      debugPrint('❌ Error cargando usuario: $e');
      
      // Si falla, limpiar todo
      _accessToken = null;
      _refreshToken = null;
      _currentUser = null;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      notifyListeners();
    }
  }

  Future<bool> isLoggedIn() async {
    await _loadUserData();
    return _accessToken != null && _currentUser != null;
  }
}