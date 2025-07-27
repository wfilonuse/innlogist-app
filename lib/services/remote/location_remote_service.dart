import '../base_data_service.dart';
import '../../models/location.dart';
import 'package:http/http.dart' as http;
import '../../build_config.dart';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationRemoteService extends BaseDataService<Location> {
  @override
  Future<void> insert(Location item) => update(item);

  @override
  Future<void> update(Location location) async {
    final token = await super.getToken();
    final response = await http.post(
      Uri.parse('${BuildConfig.baseUrl}/geo/set-list'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(location.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update location: ${response.statusCode}');
    }
  }

  @override
  Future<void> delete(dynamic id) async {
    // Реалізуйте, якщо є endpoint для видалення локації
  }

  @override
  Future<List<Location>> getAll() async {
    // No direct endpoint for all locations, return empty list or implement if needed
    return [];
  }

  @override
  Future<Location?> getById(dynamic id) async {
    // No direct endpoint for single location, return null or implement if needed
    return null;
  }

  @override
  Future<void> syncFromLocal(List<Location> items) async {
    for (final location in items) {
      await update(location);
    }
  }

  @override
  Future<List<Location>> findWhere(bool Function(Location) test) async {
    final all = await getAll();
    return all.where(test).toList();
  }

  Future<List<LatLng>?> getRoute(int orderId, String? token,
      {String? start}) async {
    final authToken = token ?? await super.getToken();
    final response = await http.post(
      Uri.parse('${BuildConfig.baseUrl}/geo/get_route'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
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
      return route;
    }
    return null;
  }
}
