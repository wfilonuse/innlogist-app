import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:inn_logist_app/models/document.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'database_helper.dart';
import 'models/order.dart';
import 'models/driver.dart';
import 'models/expense.dart';
import 'models/downloaded_file.dart';
import 'models/report.dart';
import 'models/auth_request.dart';
import 'models/auth_response.dart';
import 'models/address.dart';
import 'models/progress.dart';
import 'build_config.dart';
import 'constants.dart';

class ApiService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<AuthResponse> login(AuthRequest request) async {
    final response = await http.post(
      Uri.parse('${BuildConfig.baseUrl}/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', authResponse.token);
      await _dbHelper.upsertDriver(authResponse.driver);
      // await _dbHelper.upsertTransport(authResponse.transport);
      return authResponse;
    } else {
      throw Exception('Failed to login: ${response.statusCode}');
    }
  }

  Future<void> logout() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${BuildConfig.baseUrl}/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    } else {
      throw Exception('Failed to logout: ${response.statusCode}');
    }
  }

  Future<String> refreshToken() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${BuildConfig.baseUrl}/refresh'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newToken = data['token'] as String;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', newToken);
      return newToken;
    } else {
      throw Exception('Failed to refresh token: ${response.statusCode}');
    }
  }

  Future<List<Order>> getOrders(
      {String? status, String? dateFrom, String? dateTo}) async {
    final token = await _getToken();
    final queryParams = {
      if (status != null) 'status': status,
      if (dateFrom != null) 'date_from': dateFrom,
      if (dateTo != null) 'date_to': dateTo,
    };
    final uri = Uri.parse('${BuildConfig.baseUrl}/orders')
        .replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final orders =
          (data['data'] as List).map((json) => Order.fromJson(json)).toList();
      for (var order in orders) {
        await _dbHelper.upsertOrder(order);
      }
      return orders;
    } else {
      return _dbHelper.getAllOrders();
    }
  }

  Future<Order> getOrderDetails(int id) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${BuildConfig.baseUrl}/orders/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final order = Order.fromJson(data['data']);
      await _dbHelper.upsertOrder(order);
      return order;
    } else {
      throw Exception('Failed to load order details: ${response.statusCode}');
    }
  }

  Future<List<Progress>> getProgress(int orderId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${BuildConfig.baseUrl}/progress/$orderId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['result'] as List)
          .map((json) => Progress.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load progress: ${response.statusCode}');
    }
  }

  Future<void> updateProgress(int orderId, Progress progress) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('${BuildConfig.baseUrl}/progress/check/$orderId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'data': progress.toJson()}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update progress: ${response.statusCode}');
    }
    await _dbHelper.upsertProgress(progress, orderId);
  }

  Future<List<Document>> getDocuments(int orderId) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('${BuildConfig.baseUrl}/documents'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'order_id': orderId}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final documents =
          (data as List).map((json) => Document.fromJson(json)).toList();
      for (var doc in documents) {
        await _dbHelper.upsertDownloadedFile(DownloadedFile(
          id: doc.id,
          orderId: orderId,
          fileName: doc.fileName,
        ));
      }
      return documents;
    } else {
      return (await _dbHelper.getDownloadedFiles())
          .map((file) => Document(
                id: file.id,
                name: file.fileName,
                fileName: file.fileName,
                scope: '',
              ))
          .toList();
    }
  }

  Future<Document> uploadDocument(
      int orderId, int templateId, String filePath) async {
    final token = await _getToken();
    final file = File(filePath);
    if (file.lengthSync() > Constants.maxFileSize) {
      throw Exception('File size exceeds maximum allowed');
    }
    final mimeType = path.extension(filePath).toLowerCase();
    if (!Constants.allowedFileTypes.contains(mimeType)) {
      throw Exception('Invalid file type');
    }

    final request = http.MultipartRequest(
        'POST', Uri.parse('${BuildConfig.baseUrl}/order-document'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['order_id'] = orderId.toString();
    request.fields['template_id'] = templateId.toString();
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      final document = Document.fromJson(jsonDecode(responseBody)['data']);
      await _dbHelper.upsertDownloadedFile(DownloadedFile(
        id: document.id,
        orderId: orderId,
        fileName: document.fileName,
      ));
      return document;
    } else {
      throw Exception('Failed to upload document: ${response.statusCode}');
    }
  }

  Future<void> deleteDocument(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('${BuildConfig.baseUrl}/order-document/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      await _dbHelper.deleteDownloadedFile(id);
    } else {
      throw Exception('Failed to delete document: ${response.statusCode}');
    }
  }

  Future<Driver> getDriverProfile() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${BuildConfig.baseUrl}/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final driver = Driver.fromJson(data['data']['driver']);
      await _dbHelper.upsertDriver(driver);
      return driver;
    } else {
      final driver = await _dbHelper.getDriver(1);
      if (driver != null) return driver;
      throw Exception('Failed to load driver profile: ${response.statusCode}');
    }
  }

  Future<void> addExpense(Expense expense) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('${BuildConfig.baseUrl}/report/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(expense.toJson()),
    );
    if (response.statusCode == 200) {
      await _dbHelper.upsertExpense(expense);
    } else {
      await _dbHelper.upsertExpense(expense);
      throw Exception('Failed to add expense: ${response.statusCode}');
    }
  }

  Future<List<Address>> autocompleteAddress(String input) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('${BuildConfig.baseUrl}/autocomplete'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'input': input}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List)
          .map((json) => Address.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to autocomplete address: ${response.statusCode}');
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<Report>> getAllReports() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${BuildConfig.baseUrl}/report/all'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((json) => Report.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reports: ${response.statusCode}');
    }
  }

  Future<void> addReport(Report report) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('${BuildConfig.baseUrl}/report/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(report.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add report: ${response.statusCode}');
    }
  }

  Future<void> updateReport(Report report) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('${BuildConfig.baseUrl}/report/update/${report.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(report.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update report: ${response.statusCode}');
    }
  }

  Future<void> deleteReport(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('${BuildConfig.baseUrl}/report/delete/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete report: ${response.statusCode}');
    }
  }
}
