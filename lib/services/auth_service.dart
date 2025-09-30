import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  String? _token;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _currentUser != null;

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
      _token = prefs.getString(Constants.tokenKey);
      
      final userJson = prefs.getString(Constants.userKey);
      if (userJson != null) {
        _currentUser = User.fromJson(json.decode(userJson));
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_token != null) {
        await prefs.setString(Constants.tokenKey, _token!);
      }
      
      if (_currentUser != null) {
        await prefs.setString(Constants.userKey, json.encode(_currentUser!.toJson()));
      }
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    await Future.delayed(const Duration(seconds: 1));
    // Datos de prueba
    if (email == 'prueba@email.com' && password == 'test1234') {
      _token = 'token_de_prueba';
      _currentUser = User(
        nombre: 'Prueba',
        apellidos: 'Test Usuario',
        fechaNacimiento: DateTime(2000, 1, 1),
        sexo: 'Masculino',
        correo: email,
      );
      await _saveUserData();
      notifyListeners();
    } else {
      _setLoading(false);
      throw Exception('Credenciales incorrectas (modo prueba)');
    }
    _setLoading(false);
  }

  Future<void> register(User user, String password) async {
    _setLoading(true);
    await Future.delayed(const Duration(seconds: 1));
    // Simulación de registro exitoso
    _token = 'token_de_prueba';
    _currentUser = user;
    await _saveUserData();
    notifyListeners();
    _setLoading(false);
  }

  Future<void> resetPassword(String email) async {
    _setLoading(true);
    
    try {
      await _apiService.post(
        Constants.resetPasswordEndpoint,
        {'correo': email},
      );
    } catch (e) {
      debugPrint('Reset password error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(Constants.tokenKey);
      await prefs.remove(Constants.userKey);
      
      _token = null;
      _currentUser = null;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUser(User updatedUser) async {
    _currentUser = updatedUser;
    await _saveUserData();
    notifyListeners();
  }
}