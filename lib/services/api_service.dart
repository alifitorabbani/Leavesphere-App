import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;
  ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => message;
}

class ApiService {
  // IMPORTANT: change this to match your Laravel server address.
  // - Android Emulator: use 10.0.2.2 instead of localhost
  // - Real device (same WiFi as your PC): use your PC's local IP, e.g. http://192.168.1.5:8000/api
  // - iOS Simulator: http://localhost:8000/api works fine
  static const String baseUrl = 'http://192.168.18.170:8000/api';

  static const _tokenKey = 'auth_token';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<bool> hasToken() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (withAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    if (response.statusCode == 422) {
      throw ApiException(
        body['message'] ?? 'Validasi gagal.',
        statusCode: 422,
        errors: body['errors'],
      );
    }

    if (response.statusCode == 401) {
      throw ApiException('Sesi berakhir, silakan login kembali.', statusCode: 401);
    }

    throw ApiException(
      body['message'] ?? 'Terjadi kesalahan. Coba lagi.',
      statusCode: response.statusCode,
    );
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: await _headers())
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Tidak dapat terhubung ke server. Periksa koneksi Anda.');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data, {bool withAuth = true}) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: await _headers(withAuth: withAuth),
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Tidak dapat terhubung ke server. Periksa koneksi Anda.');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: await _headers(),
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Tidak dapat terhubung ke server. Periksa koneksi Anda.');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl$endpoint'), headers: await _headers())
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Tidak dapat terhubung ke server. Periksa koneksi Anda.');
    }
  }
}
