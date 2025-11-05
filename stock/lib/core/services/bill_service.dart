import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';

class BillService {
  static Future<Map<String, dynamic>> create({
    required int doctorId,
    int? clinicId,
    required int supplierId,
    required DateTime date,
    required List<Map<String, dynamic>> lines,
    bool paid = false,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/bills'),
      headers: ApiConfig.defaultHeaders,
      body: json.encode({
        'doctorId': doctorId,
        if (clinicId != null) 'clinicId': clinicId,
        'supplierId': supplierId,
        'date': date.toIso8601String(),
        'paid': paid,
        'lines': lines,
      }),
    );
    final data = json.decode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 201 && data['success'] == true) return data['data'] as Map<String, dynamic>;
    throw Exception(data['message'] ?? 'Failed to create bill');
  }

  static Future<List<Map<String, dynamic>>> list(int doctorId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/bills').replace(queryParameters: {'doctorId': '$doctorId'});
    final res = await http.get(uri, headers: ApiConfig.defaultHeaders);
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      final list = (data['data'] as List).cast<dynamic>();
      return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
    }
    throw Exception('Failed to load bills');
  }

  static Future<Map<String, dynamic>> get(int billId) async {
    final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/bills/$billId'), headers: ApiConfig.defaultHeaders);
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      return (data['data'] as Map).cast<String, dynamic>();
    }
    final err = json.decode(res.body) as Map<String, dynamic>;
    throw Exception(err['message'] ?? 'Failed to get bill');
  }
}


