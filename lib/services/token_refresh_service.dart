import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../build_config.dart';
import '../constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class TokenRefreshService {
  static final TokenRefreshService instance = TokenRefreshService._init();
  TokenRefreshService._init();

  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  Future<void> ensureTokenValid(BuildContext context) async {
    if (_isRefreshing) {
      await _refreshCompleter?.future;
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final expiresIn = prefs.getInt('expires_in') ?? 0;
    final lastRefresh = prefs.getInt('last_refresh') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (expiresIn > 0 &&
        now >=
            lastRefresh + expiresIn - Constants.tokenRefreshThresholdSeconds) {
      await refreshToken(context);
    }
  }

  Future<void> refreshToken(BuildContext context) async {
    _isRefreshing = true;
    _refreshCompleter = Completer<void>();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('No token');
      final response = await http.get(
        Uri.parse('${BuildConfig.baseUrl}/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        // final data = response.body;
        // Очікуємо, що відповідь містить новий токен
        // {
        //   "token": "...",
        // }
        final json = response.body.isNotEmpty ? response.body : '{}';
        final tokenData = jsonDecode(json);
        final newToken = tokenData['token'] as String?;
        if (newToken != null) {
          await prefs.setString('token', newToken);
          await prefs.setInt(
              'last_refresh', DateTime.now().millisecondsSinceEpoch ~/ 1000);
        }
      } else if (response.statusCode == 401) {
        _navigateToAuth(context);
      } else {
        throw Exception('Failed to refresh token: ${response.statusCode}');
      }
    } catch (e) {
      _navigateToAuth(context);
    } finally {
      _isRefreshing = false;
      _refreshCompleter?.complete();
    }
  }

  void _navigateToAuth(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
  }

  bool get isRefreshing => _isRefreshing;
}
