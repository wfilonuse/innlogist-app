import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inn_logist_app/services/local/driver_local_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/driver.dart';
import '../../build_config.dart';

class ProfileService {
  final DriverLocalService _driverLocalService = DriverLocalService();

  Future<Driver?> getProfile() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${BuildConfig.baseUrl}/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final driver = Driver.fromJson(data['data']['driver']);
      await _driverLocalService.insert(driver);
      return driver;
    } else if (response.statusCode == 401) {
      // Unauthorized, handle token refresh or re-login
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      return null;
    } else {
      throw Exception('Failed to load profile: ${response.statusCode}');
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
