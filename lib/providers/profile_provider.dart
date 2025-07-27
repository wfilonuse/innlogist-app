import 'package:flutter/material.dart';
import '../models/driver.dart';
import '../services/remote/profile_service.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  Driver? _driver;
  Driver? get driver => _driver;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();
    _driver = await _profileService.getProfile();
    _isLoading = false;
    notifyListeners();
  }
}
