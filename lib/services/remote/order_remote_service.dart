import 'package:inn_logist_app/models/sync_task.dart';

import '../base_data_service.dart';
import '../../models/order.dart';
import 'package:http/http.dart' as http;
import '../../build_config.dart';
import 'dart:convert';

class OrderRemoteService extends BaseDataService<Order> {
  @override
  Future<void> insert(Order item) => update(item);

  @override
  Future<void> update(Order order) async {
    final token = await super.getToken();
    final response = await http.post(
      Uri.parse('${BuildConfig.baseUrl}/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(order.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update order: ${response.statusCode}');
    }
  }

  @override
  Future<void> delete(dynamic id) async {
    final token = await super.getToken();
    final response = await http.delete(
      Uri.parse('${BuildConfig.baseUrl}/orders/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete order: ${response.statusCode}');
    }
  }

  @override
  Future<List<Order>> getAll() async {
    final token = await super.getToken();
    final response = await http.get(
      Uri.parse('${BuildConfig.baseUrl}/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List)
          .map((json) => Order.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load orders');
  }

  @override
  Future<Order?> getById(dynamic id) async {
    final token = await super.getToken();
    final response = await http.get(
      Uri.parse('${BuildConfig.baseUrl}/orders/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Order.fromJson(data['data']);
    }
    return null;
  }

  @override
  Future<void> syncFromLocal(List<Order> items) async {
    for (final order in items) {
      await update(order);
    }
  }

  @override
  Future<List<Order>> findWhere(bool Function(Order) test) async {
    final all = await getAll();
    return all.where(test).toList();
  }

  @override
  Future<void> insertFromTask(SyncTask task) async {
    final order = Order.fromJson(task.data);
    await update(order);
  }

  @override
  Future<void> updateFromTask(SyncTask task) async {
    final order = Order.fromJson(task.data);
    await update(order);
  }

  @override
  Future<void> deleteFromTask(SyncTask task) async {
    final id = task.data['id'];
    await delete(id);
  }
}
