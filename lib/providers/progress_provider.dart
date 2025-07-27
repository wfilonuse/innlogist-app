import '../services/local/progress_local_service.dart';
import '../services/remote/progress_remote_service.dart';
import 'base_provider.dart';
import '../models/progress.dart';

class ProgressProvider extends BaseProvider<Progress> {
  ProgressProvider() {
    localService = ProgressLocalService();
    remoteService = ProgressRemoteService();
  }
}
