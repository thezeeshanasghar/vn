import 'dart:convert';

import 'package:http/http.dart' as http;

class PaClinicInventoryService {
  static const String baseUrl = 'http://localhost:3000/api';

  static Map<String, String> get _headers => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Future<List<Map<String, dynamic>>> getInventoryByClinic(int clinicId) async {
    final uri = Uri.parse('$baseUrl/clinic-inventory/clinic/$clinicId');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> data = body['data'] as List<dynamic>? ?? [];
      return data.map((item) => (item as Map<String, dynamic>)).toList();
    }

    throw Exception('Failed to load clinic inventory');
  }
}

