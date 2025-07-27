import '../services/local/document_local_service.dart';
import '../services/remote/document_remote_service.dart';
import 'base_provider.dart';
import '../models/document.dart';

class DocumentProvider extends BaseProvider<Document> {
  DocumentProvider() {
    localService = DocumentLocalService();
    remoteService = DocumentRemoteService();
  }
}
