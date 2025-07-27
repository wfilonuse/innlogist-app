import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/auth_request.dart';
import '../models/auth_response.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<AuthResponse?> login(AuthRequest request) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await _authService.login(request);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  Future<String> refreshToken() async {
    return await _authService.refreshToken();
  }
}
