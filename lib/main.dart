import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';
import 'l10n/app_localizations.dart';
import 'build_config.dart';
import 'constants.dart';

void main() {
  const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: Constants.envDev);
  BuildConfig.setEnvironment(environment);
  runApp(const InnLogistApp());
}

class InnLogistApp extends StatelessWidget {
  const InnLogistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inn Logist App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('uk', ''),
      ],
      home: const AuthCheckScreen(),
    );
  }
}

// Екран перевірки авторизації
class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  _AuthCheckScreenState createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    setState(() {
      _isAuthenticated = token != null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _isAuthenticated ? const MainScreen() : const AuthScreen();
  }
}