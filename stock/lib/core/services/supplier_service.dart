import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';

class SupplierService {
  static Future<List<Map<String, dynamic>>> list(int doctorId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/suppliers').replace(queryParameters: {'doctorId': '$doctorId'});
    final res = await http.get(uri, headers: ApiConfig.defaultHeaders);
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      final list = (data['data'] as List).cast<dynamic>();
      return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
    }
    throw Exception('Failed to load suppliers');
  }

  static Future<Map<String, dynamic>> create(int doctorId, String name, String mobileNumber) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/suppliers'),
      headers: ApiConfig.defaultHeaders,
      body: json.encode({'name': name, 'mobileNumber': mobileNumber, 'doctorId': doctorId}),
    );
    if (res.statusCode == 201) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      return (data['data'] as Map).cast<String, dynamic>();
    }
    final err = json.decode(res.body) as Map<String, dynamic>;
    throw Exception(err['message'] ?? 'Failed to create supplier');
  }

  static Future<Map<String, dynamic>> update(int supplierId, String name, String mobileNumber) async {
    final res = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/suppliers/$supplierId'),
      headers: ApiConfig.defaultHeaders,
      body: json.encode({'name': name, 'mobileNumber': mobileNumber}),
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      return (data['data'] as Map).cast<String, dynamic>();
    }
    final err = json.decode(res.body) as Map<String, dynamic>;
    throw Exception(err['message'] ?? 'Failed to update supplier');
  }

  static Future<void> remove(int supplierId) async {
    final res = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/suppliers/$supplierId'),
      headers: ApiConfig.defaultHeaders,
    );
    if (res.statusCode != 200) {
      final err = json.decode(res.body) as Map<String, dynamic>;
      throw Exception(err['message'] ?? 'Failed to delete supplier');
    }
  }
}


