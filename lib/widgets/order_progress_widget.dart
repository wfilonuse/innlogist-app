import 'package:flutter/material.dart';
import 'package:inn_logist_app/providers/progress_provider.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../models/progress.dart';
import '../l10n/app_localizations.dart';
import 'common/custom_loader.dart';

class OrderProgressWidget extends StatefulWidget {
  final int orderId;

  const OrderProgressWidget({super.key, required this.orderId});

  @override
  _OrderProgressWidgetState createState() => _OrderProgressWidgetState();
}

class _OrderProgressWidgetState extends State<OrderProgressWidget> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<OrderProvider>(context, listen: false)
        .fetchItems(); // fetches all orders
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateProgress(int orderId, Progress progress) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<ProgressProvider>(context, listen: false)
          .remoteService
          .update(progress);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context).translate('progressUpdated'))),
      );
      await _loadProgress();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('error', args: {'error': e.toString()})),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<OrderProvider>(context).items;
    final order = orders.firstWhere((o) => o.id == widget.orderId);
    final progressList = order.progress ?? [];

    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _isLoading
              ? const CustomLoader()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('orderProgress'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...progressList.map((progress) => ListTile(
                          title: Text(progress.name),
                          subtitle: Text(
                            '${AppLocalizations.of(context).translate('completed')}: ${progress.completed == 1 ? AppLocalizations.of(context).translate('completed') : AppLocalizations.of(context).translate('notCompleted')}, ${AppLocalizations.of(context).translate('date')}: ${progress.date}',
                          ),
                          trailing: Icon(progress.completed == 1
                              ? Icons.check_circle
                              : Icons.circle_outlined),
                          onTap: () async {
                            await _updateProgress(widget.orderId, progress);
                          },
                        )),
                  ],
                ),
        ),
      ),
    );
  }
}
