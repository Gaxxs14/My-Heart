import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String _baseUrl = ApiConstants.baseUrl;
  String? _token;

  String get baseUrl => _baseUrl;
  String? get token => _token;

  void setBaseUrl(String url) {
    _baseUrl = url;
  }

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
    } catch (_) {}
  }

  Future<void> setToken(String? token) async {
    _token = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (token != null) {
        await prefs.setString('auth_token', token);
      } else {
        await prefs.remove('auth_token');
      }
    } catch (_) {}
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Generic GET with extended 45s Timeout for cloud cold-starts
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl$endpoint'),
            headers: _headers(),
          )
          .timeout(const Duration(seconds: 45));
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('El servidor en la nube está despertando. Por favor intenta de nuevo en unos segundos.');
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        throw Exception('No se pudo conectar al servidor. Revisa tu conexión a internet.');
      }
      rethrow;
    }
  }

  // Generic POST with extended 45s Timeout
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl$endpoint'),
            headers: _headers(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 45));
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('El servidor en la nube está despertando. Por favor intenta de nuevo en unos segundos.');
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        throw Exception('No se pudo conectar al servidor. Revisa tu conexión a internet.');
      }
      rethrow;
    }
  }

  // Generic PATCH with extended 45s Timeout
  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$_baseUrl$endpoint'),
            headers: _headers(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 45));
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('El servidor en la nube está despertando. Por favor intenta de nuevo en unos segundos.');
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        throw Exception('No se pudo conectar al servidor. Revisa tu conexión a internet.');
      }
      rethrow;
    }
  }

  // Generic DELETE with extended 45s Timeout
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$_baseUrl$endpoint'),
            headers: _headers(),
          )
          .timeout(const Duration(seconds: 45));
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('El servidor en la nube está despertando. Por favor intenta de nuevo en unos segundos.');
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        throw Exception('No se pudo conectar al servidor. Revisa tu conexión a internet.');
      }
      rethrow;
    }
  }

  dynamic _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Error en la solicitud (${response.statusCode})');
      }
    } on FormatException {
      if (response.statusCode >= 500) {
        throw Exception('El servidor se está iniciando en la nube. Por favor espera unos momentos.');
      }
      throw Exception('Respuesta inesperada del servidor (${response.statusCode})');
    }
  }
}
