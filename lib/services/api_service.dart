import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/error_messages.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;

  void setAuthToken(String? token) {
    _authToken = token;
    debugPrint('🔑 Token actualizado en ApiService: ${token != null ? "Presente" : "Null"}');
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  Future<dynamic> get(String endpoint) async {
    debugPrint('🔑 Token presente: ${_authToken != null}');
    debugPrint('🌐 GET URL: ${Constants.baseUrl}$endpoint');
    
    try {
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}$endpoint'),
        headers: _headers,
      );

      debugPrint('📡 Status Code: ${response.statusCode}');
      debugPrint('📡 Response Body: ${response.body}');

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(ErrorMessages.noConnection);
    } on TimeoutException {
      throw ApiException(ErrorMessages.timeout);
    } catch (e) {
      debugPrint('❌ Exception en GET: $e');
      if (e is ApiException) rethrow;
      throw ApiException(ErrorMessages.unexpectedError);
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    debugPrint('🔑 Token presente: ${_authToken != null}');
    debugPrint('🌐 POST URL: ${Constants.baseUrl}$endpoint');
    debugPrint('📦 Body antes de encode:');
    data.forEach((key, value) {
      debugPrint('   $key: $value (${value.runtimeType})');
    });
    
    final bodyJson = json.encode(data);
    debugPrint('📦 Body JSON string: $bodyJson');
    
    try {
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}$endpoint'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
        body: bodyJson,
      );
      
      debugPrint('📡 Status Code: ${response.statusCode}');
      debugPrint('📡 Response Headers: ${response.headers}');
      debugPrint('📡 Response Body: ${response.body}');
      
      return _handleResponse(response);
    } on SocketException {
      debugPrint('🔌 Error de conexión');
      throw ApiException(ErrorMessages.noConnection);
    } on TimeoutException {
      throw ApiException(ErrorMessages.timeout);
    } catch (e) {
      debugPrint('❌ Exception en POST: $e');
      if (e is ApiException) rethrow;
      throw ApiException(ErrorMessages.unexpectedError);
    }
  }

  // Método específico para form data (necesario para login)
  Future<Map<String, dynamic>> postFormData(String endpoint, Map<String, String> data) async {
    try {
      final url = '${Constants.baseUrl}$endpoint';
      debugPrint('🌐 POST Request URL: $url');
      debugPrint('📤 POST Data: $data');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
        body: data,
      );

      debugPrint('📥 Response Status: ${response.statusCode}');
      debugPrint('📥 Response Body: ${response.body}');

      return _handleResponse(response);
    } on SocketException catch (e) {
      debugPrint('🔌 SocketException: $e');
      throw ApiException(ErrorMessages.noConnection);
    } on TimeoutException {
      throw ApiException(ErrorMessages.timeout);
    } catch (e) {
      debugPrint('💥 Unexpected error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(ErrorMessages.unexpectedError);
    }
  }

  dynamic _handleResponse(http.Response response) {
    try {
      // Intentar decodificar como JSON
      final responseData = json.decode(response.body);
      
      switch (response.statusCode) {
        case 200:
        case 201:
          // ✅ Puede ser Map o List
          return responseData;
          
        case 400:
          final detail = responseData['detail'] ?? responseData['message'];
          final friendlyMessage = ErrorMessages.parseErrorDetail(detail);
          throw ApiException(friendlyMessage, 400);
          
        case 401:
          final detail = responseData['detail'] ?? responseData['message'];
          // Si el detalle menciona credenciales incorrectas
          if (detail != null && detail.toString().toLowerCase().contains('incorrect')) {
            throw ApiException(ErrorMessages.invalidCredentials, 401);
          }
          throw ApiException(ErrorMessages.sessionExpired, 401);
          
        case 403:
          throw ApiException(ErrorMessages.permissionDenied, 403);
          
        case 404:
          throw ApiException(ErrorMessages.notFound, 404);
          
        case 422:
          if (responseData['detail'] is List) {
            final errors = responseData['detail'] as List;
            // Extraer mensajes de error más específicos
            final errorMessages = errors.map((error) {
              final field = error['loc']?.last ?? '';
              final msg = error['msg'] ?? '';
              
              // Traducir campos comunes
              String fieldName = field;
              switch (field.toString().toLowerCase()) {
                case 'email':
                  fieldName = 'correo electrónico';
                  break;
                case 'password':
                  fieldName = 'contraseña';
                  break;
                case 'first_name':
                  fieldName = 'nombre';
                  break;
                case 'last_name':
                  fieldName = 'apellidos';
                  break;
                case 'birth_date':
                  fieldName = 'fecha de nacimiento';
                  break;
                case 'gender':
                  fieldName = 'sexo';
                  break;
              }
              
              if (msg.toLowerCase().contains('missing') || msg.toLowerCase().contains('required')) {
                return 'El campo $fieldName es obligatorio';
              } else if (msg.toLowerCase().contains('invalid')) {
                return 'El $fieldName no es válido';
              } else if (msg.toLowerCase().contains('too short')) {
                return 'El $fieldName es demasiado corto';
              }
              return 'Error en $fieldName';
            }).join('. ');
            
            throw ApiException(errorMessages, 422);
          }
          final detail = responseData['detail'];
          final friendlyMessage = ErrorMessages.parseErrorDetail(detail);
          throw ApiException(friendlyMessage, 422);
          
        case 500:
        case 502:
        case 503:
          throw ApiException(ErrorMessages.serverError, response.statusCode);
          
        default:
          throw ApiException(ErrorMessages.unexpectedError, response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ErrorMessages.unexpectedError);
    }
  }
}