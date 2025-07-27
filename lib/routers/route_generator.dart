import 'package:flutter/material.dart';
import '../../screens/auth_screen.dart';
import '../../screens/main_screen.dart';
import '../../screens/orders_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/expense_screen.dart';
import '../../screens/map_screen.dart';
import '../../screens/document_screen.dart';
import '../../screens/report_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case '/auth':
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case '/orders':
        return MaterialPageRoute(builder: (_) => const OrdersScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/expenses':
        return MaterialPageRoute(builder: (_) => const ExpenseScreen());
      case '/map':
        return MaterialPageRoute(builder: (_) => const MapScreen());
      case '/documents':
        return MaterialPageRoute(builder: (_) => const DocumentScreen());
      case '/reports':
        return MaterialPageRoute(builder: (_) => const ReportScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
