import 'package:inn_logist_app/services/remote/address_remote_service.dart';

import '../../models/address.dart';

class MockAddressService extends AddressRemoteService {
  final List<Address> _mockAddresses = [
    Address(
      id: 1,
      address: 'м. Київ, вул. Хрещатик, 22А',
      type: 'pickup',
      lat: 50.4501,
      lng: 30.5234,
      dateAt: '2024-06-01T09:00:00Z',
    ),
    Address(
      id: 2,
      address: 'м. Львів, вул. Шевченка, 10',
      type: 'delivery',
      lat: 49.84,
      lng: 24.03,
      dateAt: '2024-06-02T15:00:00Z',
    ),
  ];

  @override
  Future<void> insert(Address item) async {
    _mockAddresses.add(item);
  }

  @override
  Future<void> update(Address item) async {
    final index = _mockAddresses.indexWhere((a) => a.id == item.id);
    if (index != -1) _mockAddresses[index] = item;
  }

  @override
  Future<void> delete(dynamic id) async {
    _mockAddresses.removeWhere((a) => a.id == id);
  }

  @override
  Future<List<Address>> getAll() async {
    return _mockAddresses;
  }

  @override
  Future<Address?> getById(dynamic id) async {
    return _mockAddresses.firstWhere((a) => a.id == id);
  }

  @override
  Future<void> syncFromLocal(List<Address> items) async {}

  @override
  Future<List<Address>> findWhere(bool Function(Address) test) async {
    return _mockAddresses.where(test).toList();
  }
}
