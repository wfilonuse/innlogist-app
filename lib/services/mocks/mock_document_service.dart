import '../remote/document_remote_service.dart';
import '../../models/document.dart';

class MockDocumentService extends DocumentRemoteService {
  final List<Document> _mockDocuments = [
    Document(id: 1, name: 'ТТН', fileName: 'ttn.pdf', scope: 'order'),
    Document(id: 2, name: 'Накладна', fileName: 'nakladna.pdf', scope: 'order'),
    Document(id: 3, name: 'Сертифікат', fileName: 'cert.pdf', scope: 'order'),
  ];

  @override
  Future<void> insert(Document item) async {
    _mockDocuments.add(item);
  }

  @override
  Future<void> update(Document item) async {
    final index = _mockDocuments.indexWhere((d) => d.id == item.id);
    if (index != -1) _mockDocuments[index] = item;
  }

  @override
  Future<void> delete(dynamic id) async {
    _mockDocuments.removeWhere((d) => d.id == id);
  }

  @override
  Future<List<Document>> getAll() async {
    return _mockDocuments;
  }

  @override
  Future<Document?> getById(dynamic id) async {
    return _mockDocuments.firstWhere((d) => d.id == id);
  }

  @override
  Future<void> syncFromLocal(List<Document> items) async {}

  @override
  Future<List<Document>> findWhere(bool Function(Document) test) async {
    return _mockDocuments.where(test).toList();
  }
}
