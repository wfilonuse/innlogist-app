// lib/screens/document_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inn_logist_app/models/downloaded_file.dart';
import 'package:inn_logist_app/services/connectivity_service.dart';
import '../api_service.dart';
import '../database_helper.dart';
import '../models/document.dart';
import '../l10n/app_localizations.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  _DocumentScreenState createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final TextEditingController _orderIdController = TextEditingController();
  List<Document> _documents = [];
  bool _isLoading = false;

  Future<void> _loadDocuments() async {
    if (_orderIdController.text.isNotEmpty) {
      _isLoading = true;
      try {
        _documents =
            await _apiService.getDocuments(int.parse(_orderIdController.text));
      } catch (e) {
        _documents = await _dbHelper.getDocuments();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)
                  .translate('error', args: {'error': e.toString()}))),
        );
      }
      _isLoading = false;
    }
  }

  Future<void> _uploadDocument() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null && _orderIdController.text.isNotEmpty) {
      try {
        final document = await _apiService.uploadDocument(
            int.parse(_orderIdController.text), 1, pickedFile.path);
        await _dbHelper.upsertDownloadedFile(DownloadedFile(
          id: document.id,
          orderId: int.parse(_orderIdController.text),
          fileName: document.fileName,
        ));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  AppLocalizations.of(context).translate('progressUpdated'))),
        );
        _loadDocuments();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)
                  .translate('error', args: {'error': e.toString()}))),
        );
      }
    }
  }

  Future<void> _deleteDocument(Document document) async {
    final hasInternet = await ConnectivityService().hasInternetConnection();
    if (hasInternet) {
      await _apiService.deleteDocument(document.id);
      await _dbHelper.deleteDocument(document.id); // Add deleteDocument method
    } else {
      await _dbHelper.markForDeletionDocument(document.id);
    }
    _loadDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _orderIdController,
              decoration: const InputDecoration(
                labelText: 'ID замовлення',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _loadDocuments(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _uploadDocument,
              child: Text(AppLocalizations.of(context).translate('documents')),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _documents.length,
                      itemBuilder: (context, index) {
                        final document = _documents[index];
                        return ListTile(
                          title: Text(document.name),
                          subtitle: Text(document.scope),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              try {
                                await _deleteDocument(document);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(AppLocalizations.of(context)
                                          .translate('progressUpdated'))),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(AppLocalizations.of(context)
                                          .translate('error',
                                              args: {'error': e.toString()}))),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
