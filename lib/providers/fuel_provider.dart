import '../services/local/fuel_consumption_local_service.dart';
import '../services/remote/fuel_consumption_remote_service.dart';
import 'base_provider.dart';
import '../models/fuel_consumption.dart';

class FuelProvider extends BaseProvider<FuelConsumption> {
  FuelProvider() {
    localService = FuelConsumptionLocalService();
    remoteService = FuelConsumptionRemoteService();
  }
}
