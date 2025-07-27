import 'package:inn_logist_app/services/remote/expense_remote_service.dart';

import '../../models/expense.dart';

class MockExpenseService extends ExpenseRemoteService {
  final List<Expense> _mockExpenses = [
    Expense(
      id: 1,
      fuel: 100,
      parking: 20,
      parts: 50,
      other: 10,
      comment: 'Заправка',
      time: '2024-06-01T10:00:00Z',
      isPending: true,
      isDeleted: false,
    ),
    Expense(
      id: 2,
      fuel: 0,
      parking: 30,
      parts: 0,
      other: 0,
      comment: 'Парковка',
      time: '2024-06-02T12:00:00Z',
      isPending: true,
      isDeleted: false,
    ),
  ];

  @override
  Future<void> insert(Expense item) async {
    _mockExpenses.add(item);
  }

  @override
  Future<void> update(Expense item) async {
    final index = _mockExpenses.indexWhere((e) => e.id == item.id);
    if (index != -1) _mockExpenses[index] = item;
  }

  @override
  Future<void> delete(dynamic id) async {
    _mockExpenses.removeWhere((e) => e.id == id);
  }

  @override
  Future<List<Expense>> getAll() async {
    return _mockExpenses;
  }

  @override
  Future<Expense?> getById(dynamic id) async {
    return _mockExpenses.firstWhere((e) => e.id == id);
  }

  @override
  Future<void> syncFromLocal(List<Expense> items) async {}

  @override
  Future<List<Expense>> findWhere(bool Function(Expense) test) async {
    return _mockExpenses.where(test).toList();
  }
}
