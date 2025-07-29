import 'package:flutter/material.dart';
import 'package:inn_logist_app/providers/auth_provider.dart';
import 'package:inn_logist_app/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'expense_screen.dart';
import 'map_screen.dart';
import 'document_screen.dart';
import 'report_screen.dart';
import 'auth_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    OrdersScreen(),
    DocumentScreen(),
    ReportScreen(),
    MapScreen(),
    ProfileScreen(),
    ExpenseScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      Navigator.pop(context); // Закриваємо Drawer після вибору
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final userEmail = profileProvider.driver != null
        ? profileProvider.driver?.email ?? ""
        : "";
    final userAvatar = profileProvider.driver != null
        ? profileProvider.driver?.avatar ??
            "https://randomuser.me/api/portraits/men/1.jpg"
        : "https://randomuser.me/api/portraits/men/1.jpg";

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('appTitle')),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
            tooltip: loc.translate('logout'),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text(''),
              accountEmail: Text(userEmail),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(userAvatar),
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF4A90E2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: Text(loc.translate('orders')),
              selected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.document_scanner),
              title: Text(loc.translate('documents')),
              selected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: Text(loc.translate('reports')),
              selected: _selectedIndex == 2,
              onTap: () => _onItemTapped(2),
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: Text(loc.translate('map')),
              selected: _selectedIndex == 3,
              onTap: () => _onItemTapped(3),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(loc.translate('profile')),
              selected: _selectedIndex == 4,
              onTap: () => _onItemTapped(4),
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: Text(loc.translate('expenses')),
              selected: _selectedIndex == 5,
              onTap: () => _onItemTapped(5),
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}
