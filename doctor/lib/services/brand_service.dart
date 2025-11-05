import 'dart:convert';
import 'package:http/http.dart' as http;

class BrandService {
  static const String baseUrl = 'http://localhost:3000/api';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Future<List<Map<String, dynamic>>> getAllBrands() async {
    final uri = Uri.parse('$baseUrl/brands');
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      final list = (data['data'] as List).cast<dynamic>();
      return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
    }
    throw Exception('Failed to load brands: ${res.statusCode}');
  }
}

