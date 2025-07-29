import 'package:flutter/material.dart';
import 'package:inn_logist_app/screens/order_screen.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/order_card.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<OrderProvider>(context, listen: false).fetchItems();
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
    final loc = AppLocalizations.of(context);
    final orders = Provider.of<OrderProvider>(context).items;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Text(loc.translate('orders')),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (orders.isEmpty
              ? Center(
                  child: Text(
                    loc.translate('noOrdersYet'),
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return OrderCard(
                      order: order,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderScreen(order: order),
                          ),
                        );
                      },
                    );
                  },
                )),
    );
  }
}
