import 'package:inn_logist_app/services/remote/fuel_consumption_remote_service.dart';

import '../../models/fuel_consumption.dart';

class MockFuelService extends FuelConsumptionRemoteService {
  final List<FuelConsumption> _mockFuel = [
    FuelConsumption(
        id: 1,
        amount: 50.0,
        date: '2025-07-20',
        isPending: true,
        isDeleted: false),
    FuelConsumption(
        id: 2,
        amount: 30.0,
        date: '2025-07-21',
        isPending: true,
        isDeleted: false),
  ];

  @override
  Future<void> insert(FuelConsumption item) async {
    _mockFuel.add(item);
  }

  @override
  Future<void> update(FuelConsumption item) async {
    final index = _mockFuel.indexWhere((f) => f.id == item.id);
    if (index != -1) _mockFuel[index] = item;
  }

  @override
  Future<void> delete(dynamic id) async {
    _mockFuel.removeWhere((f) => f.id == id);
  }

  @override
  Future<List<FuelConsumption>> getAll() async {
    return _mockFuel;
  }

  @override
  Future<FuelConsumption?> getById(dynamic id) async {
    return _mockFuel.firstWhere((f) => f.id == id);
  }

  @override
  Future<void> syncFromLocal(List<FuelConsumption> items) async {}

  @override
  Future<List<FuelConsumption>> findWhere(
      bool Function(FuelConsumption) test) async {
    return _mockFuel.where(test).toList();
  }
}
