import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

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
      throw ApiException('Error de conexión. Verifica tu conexión a internet.');
    } catch (e) {
      debugPrint('❌ Exception en GET: $e');
      throw ApiException('Error inesperado: $e');
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
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 422) {
        final errorData = json.decode(response.body);
        
        // Log DETALLADO de errores de validación
        debugPrint('❌ Errores de validación (422):');
        if (errorData['detail'] is List) {
          for (var error in errorData['detail']) {
            debugPrint('   Campo: ${error['loc']}');
            debugPrint('   Tipo: ${error['type']}');
            debugPrint('   Mensaje: ${error['msg']}');
            if (error['input'] != null) {
              debugPrint('   Input recibido: ${error['input']}');
            }
          }
        }
        
        throw ApiException('Error 422: ${errorData['detail']}');
      } else if (response.statusCode == 401) {
        throw ApiException('No autorizado (401)');
      } else {
        final errorData = json.decode(response.body);
        throw ApiException('Error ${response.statusCode}: ${errorData['detail']}');
      }
    } on SocketException {
      debugPrint('🔌 Error de conexión');
      throw ApiException('Error de conexión. Verifica tu conexión a internet.');
    } catch (e) {
      debugPrint('❌ Exception en POST: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: $e');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${Constants.baseUrl}$endpoint'),
        headers: _headers,
        body: json.encode(data),
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Error de conexión. Verifica tu conexión a internet.');
    } catch (e) {
      throw ApiException('Error inesperado: $e');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('${Constants.baseUrl}$endpoint'),
        headers: _headers,
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Error de conexión. Verifica tu conexión a internet.');
    } catch (e) {
      throw ApiException('Error inesperado: $e');
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
      throw ApiException('Error de conexión. Verifica tu conexión a internet.');
    } catch (e) {
      debugPrint('💥 Unexpected error: $e');
      throw ApiException('Error inesperado: $e');
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
          throw ApiException(
            responseData['detail'] ?? responseData['message'] ?? 'Datos inválidos.',
            400,
          );
        case 401:
          throw ApiException('Sesión expirada. Inicia sesión nuevamente.', 401);
        case 403:
          throw ApiException('No tienes permisos para realizar esta acción.', 403);
        case 404:
          throw ApiException('Recurso no encontrado.', 404);
        case 422:
          if (responseData['detail'] is List) {
            final errors = responseData['detail'] as List;
            final errorMessages = errors
                .map((error) => error['msg'] ?? error.toString())
                .join(', ');
            throw ApiException('Errores de validación: $errorMessages', 422);
          }
          throw ApiException(
            responseData['detail'] ?? 'Error de validación.',
            422,
          );
        case 500:
          throw ApiException('Error interno del servidor.', 500);
        default:
          throw ApiException(
            'Error desconocido (${response.statusCode}): ${responseData['detail'] ?? response.body}',
            response.statusCode,
          );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error al procesar la respuesta del servidor.');
    }
  }
}