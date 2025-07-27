import 'package:inn_logist_app/models/sync_task.dart';

import '../base_data_service.dart';
import '../../models/expense.dart';
import 'package:http/http.dart' as http;
import '../../build_config.dart';
import 'dart:convert';

class ExpenseRemoteService extends BaseDataService<Expense> {
  @override
  Future<void> insert(Expense item) => update(item);

  @override
  Future<void> update(Expense expense) async {
    final token = await super.getToken();
    final response = await http.post(
      Uri.parse('${BuildConfig.baseUrl}/report/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(expense.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update expense: ${response.statusCode}');
    }
  }

  @override
  Future<void> delete(dynamic id) async {
    final token = await super.getToken();
    final response = await http.delete(
      Uri.parse('${BuildConfig.baseUrl}/report/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete expense: ${response.statusCode}');
    }
  }

  @override
  Future<List<Expense>> getAll() async {
    // No direct endpoint for all expenses, return empty list or implement if needed
    return [];
  }

  @override
  Future<Expense?> getById(dynamic id) async {
    // No direct endpoint for single expense, return null or implement if needed
    return null;
  }

  @override
  Future<void> syncFromLocal(List<Expense> items) async {
    for (final expense in items) {
      await update(expense);
    }
  }

  @override
  Future<List<Expense>> findWhere(bool Function(Expense) test) async {
    final all = await getAll();
    return all.where(test).toList();
  }

  @override
  Future<void> insertFromTask(SyncTask task) async {
    final expense = Expense.fromJson(task.data);
    await update(expense);
  }

  @override
  Future<void> updateFromTask(SyncTask task) async {
    final expense = Expense.fromJson(task.data);
    await update(expense);
  }

  @override
  Future<void> deleteFromTask(SyncTask task) async {
    final id = task.data['id'];
    await delete(id);
  }
}
