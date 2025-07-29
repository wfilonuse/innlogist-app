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
        name: 'Одежда',
        description: 'Текстиль',
        weight: 500,
        volume: 2,
        type: 'general',
      ),
      currentPrice: 15000.0,
      currency: 'UAH',
      paymentType: 'Готівка',
      arrivalTime: '02.12.2019 19:59',
      downloadDate: '2019-12-02T10:00:00Z',
      uploadDate: '2019-12-02T19:59:00Z',
      addresses: [
        Address(
          id: 1,
          address: 'Вулиця Барикадна, 35, Дніпро',
          type: 'pickup',
          lat: 48.464717,
          lng: 35.046183,
          dateAt: '2019-12-02T10:00:00Z',
        ),
        Address(
          id: 2,
          address: 'Вулиця Шолом-Алейхема, 45, Дніпро',
          type: 'delivery',
          lat: 48.464717,
          lng: 35.046183,
          dateAt: '2019-12-02T19:59:00Z',
        ),
      ],
      documents: [
        Document(id: 1, name: 'ТТН', fileName: 'ttn.pdf', scope: 'order'),
      ],
      locations: [
        Location(id: 1, lat: 48.464717, lng: 35.046183),
      ],
      progress: [
        Progress(
          id: 1,
          name: 'Завантаження',
          date: '2019-12-02T10:00:00Z',
          type: 'loading',
          position: 1,
          completed: 1,
          address: Address(
            id: 1,
            address: 'Вулиця Барикадна, 35, Дніпро',
            type: 'pickup',
            lat: 48.464717,
            lng: 35.046183,
            dateAt: '2019-12-02T10:00:00Z',
          ),
          statusId: '1',
          statusIdHistory: '1',
          statusName: 'Завантажено',
        ),
      ],
      isPending: true,
      isDeleted: false,
    ),
    Order(
      id: 2,
      status: '5',
      clientName: 'Компанія Б',
      clientPhone: '+380992223344',
      cargo: Cargo(
        id: 2,
        name: 'Продукти харчування',
        description: 'Молоко, хліб',
        weight: 300,
        volume: 1,
        type: 'food',
      ),
      currentPrice: 10000.0,
      currency: 'UAH',
      paymentType: 'Безготівка',
      arrivalTime: '02.12.2019 19:59',
      downloadDate: '2019-12-02T10:00:00Z',
      uploadDate: '2019-12-02T19:59:00Z',
      addresses: [
        Address(
          id: 1,
          address: 'Вулиця Барикадна, 35, Дніпро',
          type: 'pickup',
          lat: 48.464717,
          lng: 35.046183,
          dateAt: '2019-12-02T10:00:00Z',
        ),
        Address(
          id: 2,
          address: 'Вулиця Шолом-Алейхема, 45, Дніпро',
          type: 'delivery',
          lat: 48.464717,
          lng: 35.046183,
          dateAt: '2019-12-02T19:59:00Z',
        ),
      ],
      documents: [],
      locations: [],
      progress: [
        Progress(
          id: 2,
          name: 'Завантаження',
          date: '2019-12-02T10:00:00Z',
          type: 'loading',
          position: 1,
          completed: 0,
          address: Address(
            id: 1,
            address: 'Вулиця Барикадна, 35, Дніпро',
            type: 'pickup',
            lat: 48.464717,
            lng: 35.046183,
            dateAt: '2019-12-02T10:00:00Z',
          ),
          statusId: '5',
          statusIdHistory: '5',
          statusName: 'Заплановано',
        ),
      ],
      isPending: true,
      isDeleted: false,
    ),
    Order(
      id: 3,
      status: '2',
      clientName: 'Компанія В',
      clientPhone: '+380993334455',
      cargo: Cargo(
        id: 3,
        name: 'Напої',
        description: 'Вода, соки',
        weight: 200,
        volume: 1,
        type: 'beverage',
      ),
      currentPrice: 8000.0,
      currency: 'UAH',
      paymentType: 'Готівка',
      arrivalTime: '02.12.2019 19:59',
      downloadDate: '2019-12-02T10:00:00Z',
      uploadDate: '2019-12-02T19:59:00Z',
      addresses: [
        Address(
          id: 1,
          address: 'Вулиця Барикадна, 35, Дніпро',
          type: 'pickup',
          lat: 48.464717,
          lng: 35.046183,
          dateAt: '2019-12-02T10:00:00Z',
        ),
        Address(
          id: 2,
          address: 'Вулиця Шолом-Алейхема, 45, Дніпро',
          type: 'delivery',
          lat: 48.464717,
          lng: 35.046183,
          dateAt: '2019-12-02T19:59:00Z',
        ),
      ],
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
