import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/brand.dart';

class PaBrandService {
  static const String baseUrl = 'http://localhost:3000/api';

  static Map<String, String> get _headers => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Future<List<PaBrand>> getAllBrands() async {
    final response = await http.get(
      Uri.parse('$baseUrl/brands'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> list = data['data'] as List<dynamic>? ?? [];
      return list.map((item) => PaBrand.fromJson(item as Map<String, dynamic>)).toList();
    }

    throw Exception('Failed to load brands');
  }
}

