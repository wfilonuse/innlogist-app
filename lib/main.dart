import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:inn_logist_app/routers/route_generator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';
import 'l10n/app_localizations.dart';
import 'build_config.dart';
import 'constants.dart';
import 'providers/order_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/document_provider.dart';
import 'providers/report_provider.dart';
import 'providers/address_provider.dart';
import 'providers/fuel_provider.dart';
import 'providers/location_provider.dart';
import 'services/sync_service.dart';
import 'services/connectivity_service.dart';

void main() {
  const String environment =
      String.fromEnvironment('ENVIRONMENT', defaultValue: Constants.envDev);
  BuildConfig.setEnvironment(environment);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => FuelProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        // Додавайте інші провайдери тут
      ],
      child: const InnLogistApp(),
    ),
  );
  // Синхронізація при старті
  SyncService.instance.syncAll();
  // Синхронізація при зміні інтернету
  ConnectivityService().onConnectivityChanged.listen((_) {
    SyncService.instance.syncAll();
  });
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
      onGenerateRoute: RouteGenerator.generateRoute,
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
