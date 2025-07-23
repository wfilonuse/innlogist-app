import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../l10n/app_localizations.dart';

class GeoStatusWidget extends StatefulWidget {
  final Widget child;

  const GeoStatusWidget({super.key, required this.child});

  @override
  _GeoStatusWidgetState createState() => _GeoStatusWidgetState();
}

class _GeoStatusWidgetState extends State<GeoStatusWidget> {
  @override
  void initState() {
    super.initState();
    _checkGeoAccess();
  }

  Future<void> _checkGeoAccess() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('noGeoAccess')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context).translate('noGeoPermission')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: AppLocalizations.of(context).translate('grantPermission'),
            onPressed: () async {
              permission = await Geolocator.requestPermission();
              if (permission != LocationPermission.denied &&
                  permission != LocationPermission.deniedForever) {
                setState(() {});
              }
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
