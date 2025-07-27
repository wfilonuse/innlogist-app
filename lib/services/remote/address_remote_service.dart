import '../base_data_service.dart';
import '../../models/address.dart';
import 'package:http/http.dart' as http;
import '../../build_config.dart';
import 'dart:convert';

class AddressRemoteService extends BaseDataService<Address> {
  @override
  Future<void> insert(Address item) => update(item);

  @override
  Future<void> update(Address address) async {
    // No endpoint for updating address, implement if needed
  }

  @override
  Future<void> delete(dynamic id) async {
    // No endpoint for deleting address, implement if needed
  }

  @override
  Future<List<Address>> getAll() async {
    // No endpoint for all addresses, implement if needed
    return [];
  }

  @override
  Future<Address?> getById(dynamic id) async {
    // No endpoint for single address, implement if needed
    return null;
  }

  @override
  Future<void> syncFromLocal(List<Address> items) async {}

  @override
  Future<List<Address>> findWhere(bool Function(Address) test) async {
    final all = await getAll();
    return all.where(test).toList();
  }

  Future<List<Address>> autocomplete(String input) async {
    final token = await super.getToken();
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
    }
    throw Exception('Failed to autocomplete address');
  }
}
