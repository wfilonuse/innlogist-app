import 'package:flutter/material.dart';
import 'package:inn_logist_app/build_config.dart';
import 'package:inn_logist_app/constants.dart';
import '../api_service.dart';
import '../models/auth_request.dart';
import 'main_screen.dart';
import '../l10n/app_localizations.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _useMock = Constants.useMockData;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final request = AuthRequest(
        email: _emailController.text,
        password: _passwordController.text,
        timezone: 'Europe/Kiev',
        locale: 'ua',
      );
      await _apiService.login(request);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate('error', args: {'error': e.toString()}))),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context).translate('login'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Електронна пошта',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (BuildConfig.environment == Constants.envDev)
              Row(
                children: [
                  Checkbox(
                    value: _useMock,
                    onChanged: (val) {
                      setState(() {
                        _useMock = val ?? false;
                        Constants.useMockData = _useMock;
                      });
                    },
                  ),
                  const Text('Використовувати демо (mock) дані'),
                ],
              ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child:
                        Text(AppLocalizations.of(context).translate('login')),
                  ),
          ],
        ),
      ),
    );
  }
}
