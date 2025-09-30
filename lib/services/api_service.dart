import 'dart:convert';
import 'dart:io';
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

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
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

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
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

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
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

  Future<Map<String, dynamic>> delete(String endpoint) async {
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

  Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> responseData;

    try {
      responseData = json.decode(response.body);
    } catch (e) {
      throw ApiException('Error al procesar la respuesta del servidor.');
    }

    switch (response.statusCode) {
      case 200:
      case 201:
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
  }
}