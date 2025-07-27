import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_request.dart';
import '../models/auth_response.dart';
import '../services/local/driver_local_service.dart';
import '../services/local/transport_local_service.dart';
import '../database_helper.dart';
import '../build_config.dart';

class AuthService {
  final DriverLocalService _driverLocalService = DriverLocalService();
  final TransportLocalService _transportLocalService = TransportLocalService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<AuthResponse> login(AuthRequest request) async {
    final response = await http.post(
      Uri.parse('${BuildConfig.baseUrl}/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
      final prefs = await SharedPreferences.getInstance();
      final prevDriverId = prefs.getInt('driver_id');
      final newDriverId = authResponse.driver.id;

      // Якщо водій змінився, очистити всі локальні дані
      if (prevDriverId == null || prevDriverId != newDriverId) {
        await _dbHelper.clearLocalData();
      }

      await prefs.setString('token', authResponse.token);
      await prefs.setInt('driver_id', newDriverId);
      await _driverLocalService.insert(authResponse.driver);
      await _transportLocalService.insert(authResponse.transport);
      return authResponse;
    } else {
      throw Exception('Failed to login: ${response.statusCode}');
    }
  }

  Future<void> logout() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${BuildConfig.baseUrl}/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    } else {
      throw Exception('Failed to logout: ${response.statusCode}');
    }
  }

  Future<String> refreshToken() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${BuildConfig.baseUrl}/refresh'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newToken = data['token'] as String;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', newToken);
      return newToken;
    } else {
      throw Exception('Failed to refresh token: ${response.statusCode}');
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
