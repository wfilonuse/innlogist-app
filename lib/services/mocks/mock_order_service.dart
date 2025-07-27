import 'package:inn_logist_app/services/remote/order_remote_service.dart';

import '../../models/order.dart';
import '../../models/address.dart';
import '../../models/cargo.dart';
import '../../models/document.dart';
import '../../models/location.dart';
import '../../models/progress.dart';

class MockOrderService extends OrderRemoteService {
  final List<Order> _orders = [
    Order(
      id: 1,
      status: '1',
      clientName: 'Компанія А',
      clientPhone: '+380991112233',
      cargo: Cargo(
        id: 1,
        name: 'Будматеріали',
        description: 'Цегла, цемент',
        weight: 1000,
        volume: 10,
        type: 'general',
      ),
      currentPrice: 15000.0,
      currency: 'UAH',
      paymentType: 'Готівка',
      arrivalTime: '2025-07-25T08:00:00Z',
      downloadDate: '2025-07-24T10:00:00Z',
      uploadDate: '2025-07-25T15:00:00Z',
      addresses: [
        Address(
          id: 1,
          address: 'Київ, вул. Хрещатик',
          type: 'pickup',
          lat: 50.45,
          lng: 30.52,
          dateAt: '2025-07-24T10:00:00Z',
        ),
        Address(
          id: 2,
          address: 'Львів, вул. Шевченка',
          type: 'delivery',
          lat: 49.84,
          lng: 24.03,
          dateAt: '2025-07-25T15:00:00Z',
        ),
      ],
      documents: [
        Document(id: 1, name: 'ТТН', fileName: 'ttn.pdf', scope: 'order'),
      ],
      locations: [
        Location(id: 1, lat: 50.45, lng: 30.52),
      ],
      progress: [
        Progress(
          id: 1,
          name: 'Завантаження',
          date: '2025-07-24T10:00:00Z',
          type: 'loading',
          position: 1,
          completed: 1,
          address: Address(
            id: 1,
            address: 'Київ, вул. Хрещатик',
            type: 'pickup',
            lat: 50.45,
            lng: 30.52,
            dateAt: '2025-07-24T10:00:00Z',
          ),
          statusId: '1',
          statusIdHistory: '1',
          statusName: 'Завантажено',
        ),
        Progress(
          id: 2,
          name: 'В дорозі',
          date: '2025-07-25T14:00:00Z',
          type: 'transit',
          position: 2,
          completed: 0,
          address: Address(
            id: 2,
            address: 'Львів, вул. Шевченка',
            type: 'delivery',
            lat: 49.84,
            lng: 24.03,
            dateAt: '2025-07-25T15:00:00Z',
          ),
          statusId: '2',
          statusIdHistory: '1,2',
          statusName: 'В дорозі',
        ),
      ],
      isPending: true,
      isDeleted: false,
    ),
    Order(
      id: 2,
      status: '2',
      clientName: 'Компанія Б',
      clientPhone: '+380992223344',
      cargo: Cargo(
        id: 2,
        name: 'Продукти',
        description: 'Молоко, хліб',
        weight: 500,
        volume: 5,
        type: 'food',
      ),
      currentPrice: 10000.0,
      currency: 'UAH',
      paymentType: 'Безготівка',
      arrivalTime: '2025-07-22T08:00:00Z',
      downloadDate: '2025-07-21T09:00:00Z',
      uploadDate: '2025-07-22T11:00:00Z',
      addresses: [],
      documents: [],
      locations: [],
      progress: [],
      isPending: true,
      isDeleted: false,
    ),
  ];

  @override
  Future<void> insert(Order item) async {
    _orders.add(item);
  }

  @override
  Future<void> update(Order item) async {
    final index = _orders.indexWhere((o) => o.id == item.id);
    if (index != -1) _orders[index] = item;
  }

  @override
  Future<void> delete(dynamic id) async {
    _orders.removeWhere((o) => o.id == id);
  }

  @override
  Future<List<Order>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _orders;
  }

  @override
  Future<Order?> getById(dynamic id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _orders.firstWhere((o) => o.id == id);
  }

  @override
  Future<void> syncFromLocal(List<Order> items) async {
    // Мок: нічого не робимо
  }

  @override
  Future<List<Order>> findWhere(bool Function(Order) test) async {
    return _orders.where(test).toList();
  }
}
