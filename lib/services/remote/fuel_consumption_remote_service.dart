import '../base_data_service.dart';
import '../../models/fuel_consumption.dart';
import 'package:http/http.dart' as http;
import '../../build_config.dart';
import 'dart:convert';

class FuelConsumptionRemoteService extends BaseDataService<FuelConsumption> {
  @override
  Future<void> insert(FuelConsumption item) => update(item);

  @override
  Future<void> update(FuelConsumption fuel) async {
    final token = await super.getToken();
    final response = await http.post(
      Uri.parse('${BuildConfig.baseUrl}/fuel-consumption/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(fuel.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
          'Failed to update fuel consumption: ${response.statusCode}');
    }
  }

  @override
  Future<void> delete(dynamic id) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('${BuildConfig.baseUrl}/fuel-consumption/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          'Failed to delete fuel consumption: ${response.statusCode}');
    }
  }

  @override
  Future<List<FuelConsumption>> getAll() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('${BuildConfig.baseUrl}/fuel-consumption/all'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((json) => FuelConsumption.fromJson(json)).toList();
    }
    throw Exception('Failed to load fuel consumption');
  }

  @override
  Future<FuelConsumption?> getById(dynamic id) async {
    final all = await getAll();
    return all.firstWhere((f) => f.id == id);
  }

  @override
  Future<void> syncFromLocal(List<FuelConsumption> items) async {
    for (final fuel in items) {
      await update(fuel);
    }
  }

  @override
  Future<List<FuelConsumption>> findWhere(
      bool Function(FuelConsumption) test) async {
    final all = await getAll();
    return all.where(test).toList();
  }
}
