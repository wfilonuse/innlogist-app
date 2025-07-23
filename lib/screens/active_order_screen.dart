import 'package:flutter/material.dart';
import '../api_service.dart';
import '../models/order.dart';
import '../models/progress.dart';
import '../l10n/app_localizations.dart';

class ActiveOrderScreen extends StatefulWidget {
  final Order order;

  const ActiveOrderScreen({super.key, required this.order});

  @override
  _ActiveOrderScreenState createState() => _ActiveOrderScreenState();
}

class _ActiveOrderScreenState extends State<ActiveOrderScreen> {
  final ApiService _apiService = ApiService();
  List<Progress> _progress = [];
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
    try {
      _progress = await _apiService.getProgress(widget.order.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('errorLoadingProgress', args: {'error': e.toString()})),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.order.clientName),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${widget.order.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Статус: ${widget.order.status}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context).translate('orderProgress'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _progress.length,
                      itemBuilder: (context, index) {
                        final progress = _progress[index];
                        return ListTile(
                          title: Text(progress.name),
                          subtitle: Text('${AppLocalizations.of(context).translate('completed')}: ${progress.completed == 1 ? AppLocalizations.of(context).translate('completed') : AppLocalizations.of(context).translate('notCompleted')}, Дата: ${progress.date}'),
                          trailing: Icon(progress.completed == 1 ? Icons.check_circle : Icons.circle_outlined),
                          onTap: () async {
                            try {
                              await _apiService.updateProgress(widget.order.id, progress);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context).translate('progressUpdated'))),
                              );
                              _loadProgress();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context).translate('error', args: {'error': e.toString()})),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}