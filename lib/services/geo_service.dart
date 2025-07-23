// lib/services/geo_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'connectivity_service.dart';
import '../database_helper.dart';
import '../models/ltd_lng.dart';
import '../constants.dart';
import '../build_config.dart';

class GeoService {
  final ConnectivityService _connectivityService = ConnectivityService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  static final GeoService instance = GeoService._init();
  Timer? _locationTimer;
  Timer? _syncTimer;
  List<LtdLng> _pendingPoints = [];
  List<LatLng> _currentRoute = [];
  int? _currentOrderId;

  GeoService._init();

  Future<void> startTracking(int orderId) async {
    _currentOrderId = orderId;
    await _requestLocationPermission();
    try {
      _currentRoute = await _fetchRoute(orderId);
      await _dbHelper.upsertLocation(
          orderId,
          LtdLng(
            lat: 0.0,
            lng: 0.0,
            time: DateTime.now().millisecondsSinceEpoch,
            odometer: 0.0,
            deviation: 0.0,
            statusId: 0,
          ));
    } catch (e) {
      print('Error fetching initial route: $e');
    }

    _locationTimer =
        Timer.periodic(Constants.locationTrackingInterval, (timer) async {
      try {
        final position = await Geolocator.getCurrentPosition();
        final geoPoint = LtdLng(
          lat: position.latitude,
          lng: position.longitude,
          time: DateTime.now().millisecondsSinceEpoch,
          odometer: 0.0, // Потрібна логіка для одометра
          deviation: await _dbHelper.getDeviation(orderId),
          statusId: 0, // Потрібна логіка для statusId
        );
        await _dbHelper.upsertLocation(orderId, geoPoint);
        _pendingPoints.add(geoPoint);

        if (_currentRoute.isNotEmpty) {
          final deviation = await _dbHelper.getDeviation(orderId);
          if (deviation > Constants.maxDeviationMeters) {
            try {
              _currentRoute = await _fetchRoute(orderId,
                  start: '${position.latitude},${position.longitude}');
            } catch (e) {
              print('Error updating route: $e');
            }
          }
        }
      } catch (e) {
        print('Error tracking location: $e');
      }
    });

    _syncTimer = Timer.periodic(Constants.syncInterval, (timer) async {
      await _syncGeoPoints();
    });
  }

  void stopTracking() {
    _locationTimer?.cancel();
    _syncTimer?.cancel();
    _currentOrderId = null;
    _pendingPoints.clear();
    _currentRoute.clear();
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
    final response = await http.post(
      Uri.parse('${BuildConfig.baseUrl}/geo/get_route'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'order_id': orderId.toString(),
        if (start != null) 'start': start,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final route = (data['route'] as List)
          .map((point) => LatLng(point[0] as double, point[1] as double))
          .toList();
      final db = await _dbHelper.database;
      await db.update(
        'orders',
        {
          'locations': jsonEncode(route
              .map((e) => {'lat': e.latitude, 'lng': e.longitude})
              .toList())
        },
        where: 'id = ?',
        whereArgs: [orderId],
      );
      return route;
    } else {
      throw Exception('Failed to fetch route: ${response.statusCode}');
    }
  }

  Future<void> _syncGeoPoints() async {
    final hasInternet = await _connectivityService.hasInternetConnection();
    if (!hasInternet || _pendingPoints.isEmpty) return;

    final token = await _getToken();
    final response = await http.post(
      Uri.parse('${BuildConfig.baseUrl}/geo/set-list'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'data': _pendingPoints
            .map((point) => {
                  'order_id': _currentOrderId,
                  'lat': point.lat,
                  'lng': point.lng,
                  'time': point.time,
                  'odometer': point.odometer,
                  'deviation': point.deviation,
                  'status_id': point.statusId,
                })
            .toList(),
      }),
    );

    if (response.statusCode == 200) {
      await _dbHelper.deleteLocations(_currentOrderId!);
      _pendingPoints.clear();
    }
  }

  Future<void> syncOfflineData() async {
    final hasInternet = await _connectivityService.hasInternetConnection();
    if (!hasInternet) return;

    await _syncGeoPoints();

    final expenses = await _dbHelper.getAllExpenses();
    for (var expense in expenses) {
      try {
        if (expense.isDeleted) {
          await http.delete(
            Uri.parse('${BuildConfig.baseUrl}/report/${expense.id}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${await _getToken()}',
            },
          );
          await _dbHelper.deleteExpense(expense.time);
        } else {
          await http.post(
            Uri.parse('${BuildConfig.baseUrl}/report/update'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${await _getToken()}',
            },
            body: jsonEncode(expense.toJson()),
          );
          await _dbHelper.deleteExpense(expense.time);
        }
      } catch (e) {
        print('Failed to sync expense: $e');
      }
    }

    final files = await _dbHelper.getDownloadedFiles();
    for (var file in files) {
      try {
        if (file.isDeleted) {
          await http.delete(
            Uri.parse('${BuildConfig.baseUrl}/order-document/${file.id}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${await _getToken()}',
            },
          );
          await _dbHelper.deleteDownloadedFile(file.id);
        } else {
          final request = http.MultipartRequest(
              'POST', Uri.parse('${BuildConfig.baseUrl}/order-document'));
          request.headers['Authorization'] = 'Bearer ${await _getToken()}';
          request.fields['order_id'] = file.orderId.toString();
          request.fields['template_id'] = '1';
          request.files
              .add(await http.MultipartFile.fromPath('file', file.fileName));
          final response = await request.send();
          if (response.statusCode == 200) {
            await _dbHelper.deleteDownloadedFile(file.id);
          }
        }
      } catch (e) {
        print('Failed to sync document: $e');
      }
    }

    // Add sync for other models similarly
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  List<LatLng> getCurrentRoute() => _currentRoute;
}
