import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../build_config.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      final result = await _pingServer();
      return result;
    } catch (e) {
      print('Error checking internet connection: $e');
      return false;
    }
  }

  Future<bool> _pingServer() async {
    try {
      final result = await InternetAddress.lookup(
          BuildConfig.baseUrl.replaceAll('https://', '').split('/').first);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }
}
