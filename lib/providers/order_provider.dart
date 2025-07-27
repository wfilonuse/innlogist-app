import '../services/local/order_local_service.dart';
import '../services/remote/order_remote_service.dart';
import 'base_provider.dart';
import '../models/order.dart';

class OrderProvider extends BaseProvider<Order> {
  OrderProvider() {
    localService = OrderLocalService();
    remoteService = OrderRemoteService();
  }
}
