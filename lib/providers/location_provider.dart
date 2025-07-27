import '../services/local/location_local_service.dart';
import '../services/remote/location_remote_service.dart';
import 'base_provider.dart';
import '../models/location.dart';

class LocationProvider extends BaseProvider<Location> {
  LocationProvider() {
    localService = LocationLocalService();
    remoteService = LocationRemoteService();
  }
}
