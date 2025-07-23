import 'package:flutter/material.dart';
import '../api_service.dart';
import '../database_helper.dart';
import '../models/driver.dart';
import '../l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  Driver? _driver;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDriverProfile();
  }

  Future<void> _loadDriverProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _driver = await _apiService.getDriverProfile();
    } catch (e) {
      _driver = await _dbHelper.getDriver(1); // Припускаємо ID 1
      if (_driver == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate('error', args: {'error': e.toString()})),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _driver == null
              ? const Center(child: Text('Немає даних профілю'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context).translate('profile'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Ім\'я: ${_driver!.name}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Електронна пошта: ${_driver!.email}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Телефон: ${_driver!.phone}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Компанія: ${_driver!.companyName}', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
    );
  }
}