import 'dart:async';
import 'dart:convert';
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

  // Generic GET with Timeout
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl$endpoint'),
            headers: _headers(),
          )
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('El servidor está iniciando en la nube. Espera unos segundos e intenta de nuevo.');
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        throw Exception('No hay conexión a internet o el servidor no responde.');
      }
      rethrow;
    }
  }

  // Generic POST with Timeout
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl$endpoint'),
            headers: _headers(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('El servidor está iniciando en la nube. Espera unos segundos e intenta de nuevo.');
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        throw Exception('No hay conexión a internet o el servidor no responde.');
      }
      rethrow;
    }
  }

  // Generic PATCH with Timeout
  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$_baseUrl$endpoint'),
            headers: _headers(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('El servidor está iniciando en la nube. Espera unos segundos e intenta de nuevo.');
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        throw Exception('No hay conexión a internet o el servidor no responde.');
      }
      rethrow;
    }
  }

  // Generic DELETE with Timeout
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$_baseUrl$endpoint'),
            headers: _headers(),
          )
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('El servidor está iniciando en la nube. Espera unos segundos e intenta de nuevo.');
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        throw Exception('No hay conexión a internet o el servidor no responde.');
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
        throw Exception('El servidor se está iniciando en Render. Por favor espera unos momentos.');
      }
      throw Exception('Respuesta inesperada del servidor (${response.statusCode})');
    }
  }
}
