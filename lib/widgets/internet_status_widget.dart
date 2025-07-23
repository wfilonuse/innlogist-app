import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import '../services/geo_service.dart';
import '../l10n/app_localizations.dart';

class InternetStatusWidget extends StatefulWidget {
  final Widget child;

  const InternetStatusWidget({super.key, required this.child});

  @override
  _InternetStatusWidgetState createState() => _InternetStatusWidgetState();
}

class _InternetStatusWidgetState extends State<InternetStatusWidget> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    _checkInternet();
    _connectivityService.onConnectivityChanged.listen((result) {
      final hasInternet = result != ConnectivityResult.none;
      setState(() {
        _hasInternet = hasInternet;
      });
      if (!_hasInternet) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate('noInternet')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        GeoService.instance.syncOfflineData();
      }
    });
  }

  Future<void> _checkInternet() async {
    final hasInternet = await _connectivityService.hasInternetConnection();
    setState(() {
      _hasInternet = hasInternet;
    });
    if (!_hasInternet) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('noInternet')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
