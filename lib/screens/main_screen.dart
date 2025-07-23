import 'package:flutter/material.dart';
import 'package:inn_logist_app/screens/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'expense_screen.dart';
import 'map_screen.dart';
import 'document_screen.dart';
import 'report_screen.dart';
import '../l10n/app_localizations.dart';
import '../api_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    OrdersScreen(),
    ProfileScreen(),
    ExpenseScreen(),
    MapScreen(),
    DocumentScreen(),
    ReportScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('appTitle')),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await ApiService().logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(AppLocalizations.of(context)
                          .translate('error', args: {'error': e.toString()}))),
                );
              }
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.list),
              label: AppLocalizations.of(context).translate('orders')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: AppLocalizations.of(context).translate('profile')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.attach_money),
              label: AppLocalizations.of(context).translate('expenses')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.map),
              label: AppLocalizations.of(context).translate('map')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.document_scanner),
              label: AppLocalizations.of(context).translate('documents')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart),
              label: AppLocalizations.of(context).translate('reports')),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
