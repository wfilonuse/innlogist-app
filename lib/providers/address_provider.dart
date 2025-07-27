import '../services/local/address_local_service.dart';
import '../services/remote/address_remote_service.dart';
import 'base_provider.dart';
import '../models/address.dart';

class AddressProvider extends BaseProvider<Address> {
  AddressProvider() {
    localService = AddressLocalService();
    remoteService = AddressRemoteService();
  }
}
