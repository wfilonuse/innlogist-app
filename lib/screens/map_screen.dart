import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inn_logist_app/api_service.dart';
import '../services/geo_service.dart';
import '../services/connectivity_service.dart';
import '../widgets/internet_status_widget.dart';
import '../widgets/geo_status_widget.dart';
import '../widgets/order_progress_widget.dart';
import '../models/address.dart';
import '../l10n/app_localizations.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final GeoService _geoService = GeoService.instance;
  final ConnectivityService _connectivityService = ConnectivityService();
  final TextEditingController _searchController = TextEditingController();
  Set<Polyline> _polylines = {};
  List<Address> _addresses = [];

  @override
  void initState() {
    super.initState();
    _geoService.startTracking(1); // Приклад: orderId = 1
    _connectivityService.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _geoService.syncOfflineData();
      }
    });
    _searchController.addListener(_searchAddresses);
  }

  Future<void> _searchAddresses() async {
    if (_searchController.text.isNotEmpty) {
      try {
        _addresses =
            await ApiService().autocompleteAddress(_searchController.text);
        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate('error', args: {'error': e.toString()})),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _geoService.stopTracking();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GeoStatusWidget(
      child: InternetStatusWidget(
        child: Scaffold(
          body: Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(50.4501, 30.5234),
                  zoom: 10,
                ),
                onMapCreated: (controller) {
                  setState(() {
                    _polylines = {
                      Polyline(
                        polylineId: const PolylineId('route'),
                        points: _geoService.getCurrentRoute(),
                        color: Colors.blue,
                        width: 5,
                      ),
                    };
                  });
                },
                polylines: _polylines,
                markers: _addresses
                    .map((address) => Marker(
                          markerId: MarkerId(address.address),
                          position: LatLng(address.lat, address.lng),
                          infoWindow: InfoWindow(title: address.address),
                        ))
                    .toSet(),
              ),
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context).translate('searchAddress'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              OrderProgressWidget(orderId: 1),
            ],
          ),
        ),
      ),
    );
  }
}
