// lib/services/geo_service.dart
import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'connectivity_service.dart';
import '../services/local/location_local_service.dart';
import '../services/remote/location_remote_service.dart';
import '../models/location.dart';
import '../constants.dart';

class GeoService {
  final ConnectivityService _connectivityService = ConnectivityService();
  final LocationLocalService _locationLocalService = LocationLocalService();
  final LocationRemoteService _locationRemoteService = LocationRemoteService();
  static final GeoService instance = GeoService._init();
  Timer? _locationTimer;
  Timer? _syncTimer;
  Timer? _batchSyncTimer;
  List<Location> _pendingPoints = [];
  List<LatLng> _currentRoute = [];
  int? _currentOrderId;
  LatLng? _lastSavedPoint;
  int _lastOrderStatus = 0;

  GeoService._init();

  Future<void> startTracking(int orderId, int orderStatus) async {
    _currentOrderId = orderId;
    _lastOrderStatus = orderStatus;
    if (orderStatus != 1) {
      stopTracking();
      return;
    }
    await _requestLocationPermission();
    try {
      _currentRoute = await _fetchRoute(orderId);
      await _locationLocalService.insert(Location(
        id: null,
        lat: 0.0,
        lng: 0.0,
      ));
    } catch (e) {
      print('Error fetching initial route: $e');
    }

    _locationTimer =
        Timer.periodic(Constants.locationTrackingInterval, (timer) async {
      try {
        final position = await Geolocator.getCurrentPosition();
        final currentLatLng = LatLng(position.latitude, position.longitude);

        // Не зберігаємо, якщо координата не змінилась або менше minMovementMeters
        bool shouldSave = true;
        if (_lastSavedPoint != null) {
          final deviation = _distanceBetween(currentLatLng, _lastSavedPoint!);
          if (deviation < Constants.minMovementMeters) {
            shouldSave = false;
          }
        }
        if (shouldSave) {
          final geoPoint = Location(
            id: null,
            lat: position.latitude,
            lng: position.longitude,
          );
          await _locationLocalService.insert(geoPoint);
          _pendingPoints.add(geoPoint);
          _lastSavedPoint = currentLatLng;
        }
      } catch (e) {
        print('Error tracking location: $e');
      }
    });

    // Batch sync timer: кожні batchSyncInterval секунд відправляємо не більше batchSyncCount точок
    _batchSyncTimer =
        Timer.periodic(Constants.batchSyncInterval, (timer) async {
      await _batchSyncGeoPoints();
    });

    // Старий syncTimer для повної синхронізації (залишаємо для offline sync)
    _syncTimer = Timer.periodic(Constants.syncInterval, (timer) async {
      await syncOfflineData();
    });
  }

  void stopTracking() {
    _locationTimer?.cancel();
    _syncTimer?.cancel();
    _batchSyncTimer?.cancel();
    _currentOrderId = null;
    _pendingPoints.clear();
    _currentRoute.clear();
    _lastSavedPoint = null;
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }
  }

  Future<List<LatLng>> _fetchRoute(int orderId, {String? start}) async {
    final hasInternet = await _connectivityService.hasInternetConnection();
    if (!hasInternet) return _currentRoute;

    final token = await _getToken();
    final response =
        await _locationRemoteService.getRoute(orderId, token, start: start);
    if (response != null) {
      _currentRoute = response;
      return _currentRoute;
    } else {
      throw Exception('Failed to fetch route');
    }
  }

  Future<void> _batchSyncGeoPoints() async {
    final hasInternet = await _connectivityService.hasInternetConnection();
    if (!hasInternet || _pendingPoints.isEmpty) return;

    final batch = _pendingPoints.take(Constants.batchSyncCount).toList();
    for (final point in batch) {
      await _locationRemoteService.insert(point);
    }
    _pendingPoints.removeRange(0, batch.length);
  }

  Future<void> syncOfflineData() async {
    final hasInternet = await _connectivityService.hasInternetConnection();
    if (!hasInternet) return;

    final pendingLocations = await _locationLocalService.getPendingLocations();
    for (final location in pendingLocations) {
      try {
        await _locationRemoteService.insert(location);
        await _locationLocalService.markForDeletionLocation(location.id!);
      } catch (e) {
        print('Failed to sync location: $e');
      }
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  List<LatLng> getCurrentRoute() => _currentRoute;

  double _distanceBetween(LatLng a, LatLng b) {
    const double earthRadius = 6371000; // meters
    final lat1 = a.latitude * (3.141592653589793 / 180.0);
    final lon1 = a.longitude * (3.141592653589793 / 180.0);
    final lat2 = b.latitude * (3.141592653589793 / 180.0);
    final lon2 = b.longitude * (3.141592653589793 / 180.0);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final aVal = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(lat1) * cos(lat2) * (sin(dLon / 2) * sin(dLon / 2));
    final c = 2 * atan2(sqrt(aVal), sqrt(1 - aVal));
    return earthRadius * c;
  }
}
