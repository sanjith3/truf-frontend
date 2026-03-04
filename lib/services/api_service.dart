import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Central API service — single source of truth for backend URL.
/// All screens must call backend through this service.
///
/// RULES:
/// - Use get() / post() for PUBLIC endpoints (no auth needed)
/// - Use getAuth() / postAuth() for PROTECTED endpoints (JWT required)
/// - Never store money as double. Use String for all financial values.
class ApiService {
  // ─── BASE URL CONFIGURATION ───
  // LAN IP — NOT localhost / 127.0.0.1 / 10.0.2.2
  static const String BASE_URL = 'http://10.33.236.36:8000';

  // SharedPreferences keys for JWT tokens
  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';

  // ─── TOKEN MANAGEMENT ───

  /// Save JWT tokens after login/registration
  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    print('🔐 Tokens saved to SharedPreferences');
  }

  /// Get stored access token (returns null if not logged in)
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Get stored refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Clear tokens on logout
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    print('🔐 Tokens cleared');
  }

  /// Check if user has a stored token (does NOT verify validity)
  static Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ─── PUBLIC REQUESTS (no auth) ───

  /// GET request — no auth required (e.g. turf list, availability)
  Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    final url = Uri.parse(
      '$BASE_URL$path',
    ).replace(queryParameters: queryParams);
    print('🔥 GET $url');

    try {
      final response = await http
          .get(url, headers: _publicHeaders())
          .timeout(const Duration(seconds: 10));

      print('🔥 GET ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ApiException(response.statusCode, response.body);
      }
    } on SocketException catch (e) {
      print('🚨 SOCKET ERROR: $e');
      print('🚨 FIX: Run "adb reverse tcp:8000 tcp:8000"');
      rethrow;
    } catch (e) {
      print('🚨 GET ERROR: $e (${e.runtimeType})');
      rethrow;
    }
  }

  /// POST request — no auth required (e.g. login, registration)
  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('$BASE_URL$path');
    print('🔥 POST $url | body: $body');

    try {
      final response = await http
          .post(
            url,
            headers: _publicHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 10));

      print('🔥 POST ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw ApiException(response.statusCode, response.body);
      }
    } on SocketException catch (e) {
      print('🚨 SOCKET ERROR (POST): $e');
      rethrow;
    } catch (e) {
      print('🚨 POST ERROR: $e (${e.runtimeType})');
      rethrow;
    }
  }

  /// Multipart POST — no auth required.
  /// [fields] are plain text key-value pairs.
  /// [files] maps field name → file path.
  Future<dynamic> postMultipart(
    String path, {
    required Map<String, String> fields,
    List<File>? files,
    String fileField = 'images',
  }) async {
    final url = Uri.parse('$BASE_URL$path');
    print('🔥 MULTIPART POST $url | fields: ${fields.keys}');

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll({'Accept': 'application/json'});
      request.fields.addAll(fields);

      if (files != null) {
        for (final file in files) {
          final stream = http.ByteStream(file.openRead());
          final length = await file.length();
          final multipartFile = http.MultipartFile(
            fileField,
            stream,
            length,
            filename: file.path.split(Platform.pathSeparator).last,
          );
          request.files.add(multipartFile);
        }
      }

      final streamed = await request.send().timeout(
        const Duration(seconds: 60),
      );
      final response = await http.Response.fromStream(streamed);
      print('🔥 MULTIPART POST ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw ApiException(response.statusCode, response.body);
      }
    } on SocketException catch (e) {
      print('🚨 SOCKET ERROR (MULTIPART): $e');
      rethrow;
    } catch (e) {
      print('🚨 MULTIPART ERROR: $e (${e.runtimeType})');
      rethrow;
    }
  }

  // ─── AUTHENTICATED REQUESTS (JWT required) ───

  /// GET request with JWT Bearer token
  Future<dynamic> getAuth(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    final headers = await _authHeaders();
    final url = Uri.parse(
      '$BASE_URL$path',
    ).replace(queryParameters: queryParams);
    print('🔐 AUTH GET $url');

    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      print('🔐 AUTH GET ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw AuthExpiredException();
      } else {
        throw ApiException(response.statusCode, response.body);
      }
    } on SocketException catch (e) {
      print('🚨 SOCKET ERROR (AUTH GET): $e');
      rethrow;
    } catch (e) {
      if (e is AuthExpiredException) rethrow;
      print('🚨 AUTH GET ERROR: $e (${e.runtimeType})');
      rethrow;
    }
  }

  /// POST request with JWT Bearer token
  Future<dynamic> postAuth(String path, {Map<String, dynamic>? body}) async {
    final headers = await _authHeaders();
    final url = Uri.parse('$BASE_URL$path');
    print('🔐 AUTH POST $url | body: $body');

    try {
      final response = await http
          .post(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 10));

      print('🔐 AUTH POST ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw AuthExpiredException();
      } else {
        throw ApiException(response.statusCode, response.body);
      }
    } on SocketException catch (e) {
      print('🚨 SOCKET ERROR (AUTH POST): $e');
      rethrow;
    } catch (e) {
      if (e is AuthExpiredException) rethrow;
      print('🚨 AUTH POST ERROR: $e (${e.runtimeType})');
      rethrow;
    }
  }

  /// POST request with JWT — returns raw response (for confirm flow error handling)
  Future<http.Response> postAuthRaw(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await _authHeaders();
    final url = Uri.parse('$BASE_URL$path');
    print('🔐 AUTH POST RAW $url | body: $body');

    final response = await http
        .post(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: 15));

    print('🔐 AUTH POST RAW ${response.statusCode}: ${response.body}');
    return response;
  }

  // ─── HEADERS ───

  Map<String, String> _publicHeaders() {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) {
      throw AuthExpiredException();
    }
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}

// ─── EXCEPTIONS ───

class ApiException implements Exception {
  final int statusCode;
  final String body;

  ApiException(this.statusCode, this.body);

  @override
  String toString() => 'ApiException($statusCode): $body';
}

/// Thrown when JWT token is missing or expired (401).
/// Screens should catch this and redirect to login.
class AuthExpiredException implements Exception {
  @override
  String toString() =>
      'AuthExpiredException: JWT token missing or expired. User must re-login.';
}
