import '../services/local/report_local_service.dart';
import '../services/remote/report_remote_service.dart';
import 'base_provider.dart';
import '../models/report.dart';

class ReportProvider extends BaseProvider<Report> {
  ReportProvider() {
    localService = ReportLocalService();
    remoteService = ReportRemoteService();
  }
}
