import 'package:flutter/material.dart';
import '../api_service.dart';
import '../models/progress.dart';
import '../l10n/app_localizations.dart';

class OrderProgressWidget extends StatefulWidget {
  final int orderId;

  const OrderProgressWidget({super.key, required this.orderId});

  @override
  _OrderProgressWidgetState createState() => _OrderProgressWidgetState();
}

class _OrderProgressWidgetState extends State<OrderProgressWidget> {
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
      _progress = await _apiService.getProgress(widget.orderId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate(
              'errorLoadingProgress',
              args: {'error': e.toString()})),
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
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('orderProgress'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._progress.map((progress) => ListTile(
                          title: Text(progress.name),
                          subtitle: Text(
                            '${AppLocalizations.of(context).translate('completed')}: ${progress.completed == 1 ? AppLocalizations.of(context).translate('completed') : AppLocalizations.of(context).translate('notCompleted')}, ${AppLocalizations.of(context).translate('date')}: ${progress.date}',
                          ),
                          trailing: Icon(progress.completed == 1
                              ? Icons.check_circle
                              : Icons.circle_outlined),
                          onTap: () async {
                            try {
                              await _apiService.updateProgress(
                                  widget.orderId, progress);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(AppLocalizations.of(context)
                                        .translate('progressUpdated'))),
                              );
                              _loadProgress();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)
                                      .translate('error',
                                          args: {'error': e.toString()})),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        )),
                  ],
                ),
        ),
      ),
    );
  }
}
